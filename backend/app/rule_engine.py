from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from typing import Optional

from app.schemas import VitalIngest


STABLE_WINDOW_SEC = 30

SQI_PPG_TH = 0.80
SQI_RR_TH = 0.70
SQI_TEMP_TH = 0.60

VALID_RATIO_15M_TH = 0.70

# MVP 기본값 제안:
# 문서에는 HR/RR jump 수치 임계값이 구체적으로 없다.
# temp jump는 문서의 SQI_temp 아이디어에 0.6°C/s가 제시되어 있다.
JUMP_TEMP_MAX_C_PER_SEC = 0.60
JUMP_HR_DELTA_10S = 80
JUMP_RR_DELTA_10S = 40


STATUS_TEXT = {
    "NORMAL": ("우리 아이는 지금 안정적이에요", "평소 관리 루틴을 유지해 주세요."),
    "INTEREST": ("가벼운 변화가 보여요", "환경과 자세를 정돈한 뒤 다음 기록을 확인해 주세요."),
    "CAUTION": ("조금 더 세심한 관찰이 필요해요", "안정 후 다시 확인하고 반복되면 상담을 권장합니다."),
    "DANGER": ("빠른 확인이 필요해요", "즉시 안정시키고 가까운 병원 방문 여부를 확인해 주세요."),
    "EMERGENCY": ("지금은 즉시 대응이 필요해요", "호흡곤란, 실신, 의식저하가 있으면 지체하지 말고 이동하세요."),
    "INVALID": ("지금은 정확히 측정하기 어려워요", "움직임, 밀착, 품질 문제일 수 있으니 착용을 점검한 뒤 다시 측정해 주세요."),
}


INVALID_MESSAGES = {
    "motion": "강아지가 움직이고 있어요. 안정된 자세로 1분 뒤 다시 측정해 주세요.",
    "no_contact": "센서 밀착이 부족할 수 있어요. 하네스를 조금 더 조이거나 센서 위치를 조정해 주세요.",
    "unstable": "센서가 흔들리거나 값이 불안정해요. 착용 상태를 점검한 뒤 다시 측정해 주세요.",
    "jump": "측정값이 급변했어요. 30초 후 재측정해 주세요.",
    "sensor_error": "센서 또는 전송 오류가 의심돼요. 앱 재시도 후 지속되면 기기 점검이 필요합니다.",
}


@dataclass
class DogContext:
    dog_id: int
    weight_kg: float
    baseline_temp_c: Optional[float] = None
    heart_risk_mode: bool = False


@dataclass
class PreviousRecordContext:
    measured_at: datetime
    hr_bpm: Optional[int]
    rr_bpm: Optional[int]
    temp_est_c: Optional[float]


@dataclass
class RecentScoreContext:
    t_score: Optional[int]
    p_score: Optional[int]
    r_score: Optional[int]
    final_status: str


@dataclass
class RuleResult:
    final_status: str
    invalid_reason: Optional[str]
    t_score: Optional[int]
    p_score: Optional[int]
    r_score: Optional[int]
    avg_score: Optional[float]
    alert_required: bool
    headline: str
    message: str


def _to_float(value: object) -> Optional[float]:
    if value is None:
        return None
    if isinstance(value, Decimal):
        return float(value)
    return float(value)


def get_status_text(final_status: str, invalid_reason: Optional[str] = None) -> tuple[str, str]:
    headline, message = STATUS_TEXT[final_status]
    if final_status == "INVALID" and invalid_reason:
        return headline, INVALID_MESSAGES.get(invalid_reason, message)
    return headline, message


def is_alert_required(final_status: str) -> bool:
    return final_status in {"DANGER", "EMERGENCY"}


def _is_jump(packet: VitalIngest, previous: Optional[PreviousRecordContext]) -> bool:
    if previous is None:
        return False

    elapsed = abs((packet.ts.replace(tzinfo=None) - previous.measured_at).total_seconds())
    if elapsed <= 0 or elapsed > 15:
        return False

    if packet.temp_est_c is not None and previous.temp_est_c is not None:
        temp_rate = abs(packet.temp_est_c - previous.temp_est_c) / elapsed
        if temp_rate > JUMP_TEMP_MAX_C_PER_SEC:
            return True

    if packet.hr_bpm is not None and previous.hr_bpm is not None:
        if abs(packet.hr_bpm - previous.hr_bpm) > JUMP_HR_DELTA_10S:
            return True

    if packet.rr_bpm is not None and previous.rr_bpm is not None:
        if abs(packet.rr_bpm - previous.rr_bpm) > JUMP_RR_DELTA_10S:
            return True

    return False


def get_invalid_reason(
    packet: VitalIngest,
    previous: Optional[PreviousRecordContext] = None,
) -> Optional[str]:
    if packet.invalid_reason is not None:
        return packet.invalid_reason

    required_values = [
        packet.hr_bpm,
        packet.rr_bpm,
        packet.temp_est_c,
        packet.sqi_ppg,
        packet.sqi_rr,
        packet.sqi_temp,
    ]
    if any(value is None for value in required_values):
        return "sensor_error"

    if packet.motion_state != "stable":
        return "motion"

    if _is_jump(packet, previous):
        return "jump"

    if packet.sqi_ppg is None or packet.sqi_ppg < SQI_PPG_TH:
        # MVP 기본값 제안:
        # 문서는 PPG 실패를 unstable 또는 no_contact로 처리한다고만 제시한다.
        # 매우 낮은 SQI는 no_contact, 그 외는 unstable로 분리한다.
        if packet.sqi_ppg is not None and packet.sqi_ppg < 0.40:
            return "no_contact"
        return "unstable"

    if packet.sqi_rr is None or packet.sqi_rr < SQI_RR_TH:
        return "unstable"

    if packet.sqi_temp is None or packet.sqi_temp < SQI_TEMP_TH:
        # MVP 기본값 제안:
        # 온도 SQI가 매우 낮으면 밀착 부족으로 본다.
        if packet.sqi_temp is not None and packet.sqi_temp < 0.35:
            return "no_contact"
        return "unstable"

    return None


def calc_temp_score(temp_est_c: Optional[float], baseline_temp_c: Optional[float]) -> int:
    if temp_est_c is None:
        return 0

    absolute_score = 0
    if temp_est_c >= 40.0 or temp_est_c <= 37.0:
        absolute_score = 2
    elif 39.3 <= temp_est_c <= 39.9 or 37.1 <= temp_est_c <= 37.4:
        absolute_score = 1
    else:
        absolute_score = 0

    baseline_score = 0
    if baseline_temp_c is not None:
        delta = temp_est_c - baseline_temp_c
        if delta >= 1.5:
            baseline_score = 2
        elif delta >= 1.0:
            baseline_score = 1

    return max(absolute_score, baseline_score)


def _dog_size(weight_kg: float) -> str:
    if weight_kg < 10:
        return "small"
    if weight_kg <= 25:
        return "medium"
    return "large"


def calc_pulse_score(hr_bpm: Optional[int], weight_kg: float) -> int:
    if hr_bpm is None:
        return 0

    size = _dog_size(weight_kg)

    if size == "small":
        if 100 <= hr_bpm <= 140:
            return 0
        if 141 <= hr_bpm <= 160 or 70 <= hr_bpm <= 99:
            return 1
        return 2

    if size == "medium":
        if 80 <= hr_bpm <= 120:
            return 0
        if 121 <= hr_bpm <= 140 or 50 <= hr_bpm <= 79:
            return 1
        return 2

    if 60 <= hr_bpm <= 100:
        return 0
    if 101 <= hr_bpm <= 120 or 40 <= hr_bpm <= 59:
        return 1
    return 2


def calc_resp_score(
    rr_bpm: Optional[int],
    resp_pattern: Optional[str] = None,
    heart_risk_mode: bool = False,
) -> int:
    if rr_bpm is None:
        return 0

    if resp_pattern in {"open_mouth", "abdominal", "cyanosis"}:
        return 2

    if heart_risk_mode and rr_bpm > 30:
        return 2

    if 15 <= rr_bpm <= 30:
        return 0
    if 31 <= rr_bpm <= 40:
        return 1
    return 2


def _recent_count_with_score(
    recent_scores: list[RecentScoreContext],
    score_name: str,
    target_score: int,
) -> int:
    count = 0
    for item in recent_scores:
        value = getattr(item, score_name)
        if value == target_score:
            count += 1
        else:
            break
    return count


def upgrade_temp_to_3_if_needed(
    t_score: int,
    temp_est_c: Optional[float],
    recent_scores: list[RecentScoreContext],
) -> int:
    if temp_est_c is not None and (temp_est_c >= 40.5 or temp_est_c <= 36.5):
        return 3

    if t_score == 2 and _recent_count_with_score(recent_scores, "t_score", 2) >= 2:
        return 3

    return t_score


def upgrade_pulse_to_3_if_needed(
    p_score: int,
    hr_bpm: Optional[int],
    weight_kg: float,
    recent_scores: list[RecentScoreContext],
) -> int:
    if hr_bpm is not None:
        size = _dog_size(weight_kg)
        if size == "small" and (hr_bpm > 180 or hr_bpm < 60):
            return 3
        if size == "medium" and (hr_bpm > 160 or hr_bpm < 40):
            return 3
        if size == "large" and (hr_bpm > 140 or hr_bpm < 30):
            return 3

    if p_score == 2 and _recent_count_with_score(recent_scores, "p_score", 2) >= 2:
        return 3

    return p_score


def upgrade_resp_to_3_if_needed(
    r_score: int,
    rr_bpm: Optional[int],
    resp_pattern: Optional[str],
    red_flag: bool,
    recent_scores: list[RecentScoreContext],
) -> int:
    if red_flag:
        return 3

    if resp_pattern in {"open_mouth", "abdominal", "cyanosis"}:
        return 3

    if rr_bpm is not None and rr_bpm > 50:
        return 3

    if r_score == 2 and _recent_count_with_score(recent_scores, "r_score", 2) >= 2:
        return 3

    return r_score


def calc_final_status(
    t_score: int,
    p_score: int,
    r_score: int,
    avg_score: float,
    red_flag: bool,
) -> str:
    if red_flag or max(t_score, p_score, r_score) >= 3:
        return "EMERGENCY"
    if avg_score >= 1.50:
        return "DANGER"
    if avg_score >= 1.00:
        return "CAUTION"
    if avg_score >= 0.50:
        return "INTEREST"
    return "NORMAL"


def evaluate_vitals(
    packet: VitalIngest,
    dog: DogContext,
    previous: Optional[PreviousRecordContext] = None,
    recent_scores: Optional[list[RecentScoreContext]] = None,
) -> RuleResult:
    recent_scores = recent_scores or []

    invalid_reason = get_invalid_reason(packet, previous)
    if invalid_reason is not None:
        headline, message = get_status_text("INVALID", invalid_reason)
        return RuleResult(
            final_status="INVALID",
            invalid_reason=invalid_reason,
            t_score=None,
            p_score=None,
            r_score=None,
            avg_score=None,
            alert_required=False,
            headline=headline,
            message=message,
        )

    t_score = calc_temp_score(packet.temp_est_c, dog.baseline_temp_c)
    p_score = calc_pulse_score(packet.hr_bpm, dog.weight_kg)
    r_score = calc_resp_score(
        packet.rr_bpm,
        packet.resp_pattern,
        dog.heart_risk_mode,
    )

    t_score = upgrade_temp_to_3_if_needed(t_score, packet.temp_est_c, recent_scores)
    p_score = upgrade_pulse_to_3_if_needed(p_score, packet.hr_bpm, dog.weight_kg, recent_scores)
    r_score = upgrade_resp_to_3_if_needed(
        r_score,
        packet.rr_bpm,
        packet.resp_pattern,
        packet.red_flag,
        recent_scores,
    )

    avg_score = round((t_score + p_score + r_score) / 3, 2)

    final_status = calc_final_status(
        t_score=t_score,
        p_score=p_score,
        r_score=r_score,
        avg_score=avg_score,
        red_flag=packet.red_flag,
    )

    headline, message = get_status_text(final_status)
    return RuleResult(
        final_status=final_status,
        invalid_reason=None,
        t_score=t_score,
        p_score=p_score,
        r_score=r_score,
        avg_score=avg_score,
        alert_required=is_alert_required(final_status),
        headline=headline,
        message=message,
    )
