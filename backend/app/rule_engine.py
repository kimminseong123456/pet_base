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

# MVP defaults:
# HR/RR jump thresholds are product assumptions until clinical criteria are fixed.
# The temp jump threshold follows the draft SQI_temp idea of 0.6 C/s.
JUMP_TEMP_MAX_C_PER_SEC = 0.60
JUMP_HR_DELTA_10S = 80
JUMP_RR_DELTA_10S = 40


STATUS_TEXT = {
    "NORMAL": (
        "\uC6B0\uB9AC \uC544\uC774\uB294 \uC9C0\uAE08 \uC548\uC815\uC801\uC774\uC5D0\uC694",
        "\uD3C9\uC18C \uAD00\uB9AC \uB8E8\uD2F4\uC744 \uC774\uC5B4\uAC00 \uC8FC\uC138\uC694.",
    ),
    "INTEREST": (
        "\uAC00\uBCBC\uC6B4 \uBCC0\uD654\uAC00 \uBCF4\uC5EC\uC694",
        "\uD658\uACBD\uACFC \uC790\uC138\uB97C \uC815\uB3C8\uD55C \uB4A4 \uB2E4\uC74C \uAE30\uB85D\uC744 \uD655\uC778\uD574 \uC8FC\uC138\uC694.",
    ),
    "CAUTION": (
        "\uC870\uAE08 \uB354 \uC138\uC2EC\uD55C \uAD00\uCC30\uC774 \uD544\uC694\uD574\uC694",
        "\uC548\uC815 \uD6C4 \uB2E4\uC2DC \uD655\uC778\uD558\uACE0 \uBC18\uBCF5\uB418\uBA74 \uC0C1\uB2F4\uC744 \uAD8C\uC7A5\uD569\uB2C8\uB2E4.",
    ),
    "DANGER": (
        "\uBE60\uB978 \uD655\uC778\uC774 \uD544\uC694\uD574\uC694",
        "\uC989\uC2DC \uC548\uC815\uC2DC\uD0A4\uACE0 \uAC00\uAE4C\uC6B4 \uBCD1\uC6D0 \uBC29\uBB38 \uC5EC\uBD80\uB97C \uD655\uC778\uD574 \uC8FC\uC138\uC694.",
    ),
    "EMERGENCY": (
        "\uC9C0\uAE08\uC740 \uC989\uC2DC \uB300\uC751\uC774 \uD544\uC694\uD574\uC694",
        "\uD638\uD761\uACE4\uB780, \uC2E4\uC2E0, \uC758\uC2DD\uC800\uD558\uAC00 \uC788\uC73C\uBA74 \uC9C0\uCCB4\uD558\uC9C0 \uB9D0\uACE0 \uC774\uB3D9\uD558\uC138\uC694.",
    ),
    "INVALID": (
        "\uC9C0\uAE08\uC740 \uC815\uD655\uD788 \uCE21\uC815\uD558\uAE30 \uC5B4\uB824\uC6CC\uC694",
        "\uC6C0\uC9C1\uC784, \uBC00\uCC29, \uC2E0\uD638 \uD488\uC9C8 \uBB38\uC81C\uC77C \uC218 \uC788\uC5B4 \uCC29\uC6A9 \uC0C1\uD0DC\uB97C \uC810\uAC80\uD574 \uC8FC\uC138\uC694.",
    ),
}


INVALID_MESSAGES = {
    "motion": "\uAC15\uC544\uC9C0\uAC00 \uC6C0\uC9C1\uC774\uACE0 \uC788\uC5B4\uC694. \uC548\uC815\uB41C \uC790\uC138\uB85C 1\uBD84 \uB4A4 \uB2E4\uC2DC \uCE21\uC815\uD574 \uC8FC\uC138\uC694.",
    "no_contact": "\uC13C\uC11C \uBC00\uCC29\uC774 \uBD80\uC871\uD560 \uC218 \uC788\uC5B4\uC694. \uD558\uB124\uC2A4\uB97C \uC870\uAE08 \uB354 \uC870\uC774\uAC70\uB098 \uC13C\uC11C \uC704\uCE58\uB97C \uC870\uC815\uD574 \uC8FC\uC138\uC694.",
    "unstable": "\uC13C\uC11C\uAC00 \uD754\uB4E4\uB9AC\uAC70\uB098 \uAC12\uC774 \uBD88\uC548\uC815\uD574\uC694. \uCC29\uC6A9 \uC0C1\uD0DC\uB97C \uC810\uAC80\uD55C \uB4A4 \uB2E4\uC2DC \uCE21\uC815\uD574 \uC8FC\uC138\uC694.",
    "jump": "\uCE21\uC815\uAC12\uC774 \uAE09\uACA9\uD788 \uBCC0\uD588\uC5B4\uC694. 30\uCD08 \uB4A4 \uB2E4\uC2DC \uCE21\uC815\uD574 \uC8FC\uC138\uC694.",
    "sensor_error": "\uC13C\uC11C \uB610\uB294 \uC804\uC1A1 \uC624\uB958\uAC00 \uC758\uC2EC\uB3FC\uC694. \uC7AC\uC2DC\uC791 \uD6C4\uC5D0\uB3C4 \uC9C0\uC18D\uB418\uBA74 \uAE30\uAE30 \uC810\uAC80\uC774 \uD544\uC694\uD569\uB2C8\uB2E4.",
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
        if packet.sqi_ppg is not None and packet.sqi_ppg < 0.40:
            return "no_contact"
        return "unstable"

    if packet.sqi_rr is None or packet.sqi_rr < SQI_RR_TH:
        return "unstable"

    if packet.sqi_temp is None or packet.sqi_temp < SQI_TEMP_TH:
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
