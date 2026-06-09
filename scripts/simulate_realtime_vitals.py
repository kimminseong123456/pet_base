import argparse
import itertools
import random
import time
from datetime import datetime, timezone
from typing import Any

import requests


SCENARIOS = ["normal", "interest", "caution", "danger", "emergency", "invalid"]


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def jitter_int(value: int, spread: int) -> int:
    return value + random.randint(-spread, spread)


def jitter_float(value: float, spread: float) -> float:
    return round(value + random.uniform(-spread, spread), 2)


def build_payload(
    scenario: str,
    dog_id: int,
    device_id: str,
) -> dict[str, Any]:
    base = {
        "ts": utc_now_iso(),
        "device_id": device_id,
        "dog_id": dog_id,
        "motion_state": "stable",
        "sqi_ppg": 0.91,
        "sqi_rr": 0.88,
        "sqi_temp": 0.77,
        "invalid_reason": None,
        "battery_pct": 82,
        "red_flag": False,
        "resp_pattern": None,
    }

    if scenario == "normal":
        base.update(
            hr_bpm=jitter_int(118, 3),
            rr_bpm=jitter_int(24, 2),
            temp_est_c=jitter_float(38.4, 0.05),
        )
        return base

    if scenario == "interest":
        # 소형견 기준: T=1, P=1, R=0 -> avg=0.67 -> INTEREST
        base.update(
            hr_bpm=jitter_int(148, 2),
            rr_bpm=jitter_int(25, 1),
            temp_est_c=jitter_float(39.15, 0.03),
        )
        return base

    if scenario == "caution":
        # T=1, P=1, R=1 -> avg=1.00 -> CAUTION
        base.update(
            hr_bpm=jitter_int(152, 2),
            rr_bpm=jitter_int(34, 1),
            temp_est_c=jitter_float(39.35, 0.03),
        )
        return base

    if scenario == "danger":
        # T=2, P=2, R=1 -> avg=1.67 -> DANGER
        base.update(
            hr_bpm=jitter_int(166, 2),
            rr_bpm=jitter_int(36, 1),
            temp_est_c=jitter_float(40.05, 0.03),
        )
        return base

    if scenario == "emergency":
        # red_flag 또는 3점 확장으로 EMERGENCY
        base.update(
            hr_bpm=jitter_int(186, 2),
            rr_bpm=jitter_int(54, 1),
            temp_est_c=jitter_float(40.7, 0.03),
            red_flag=True,
            resp_pattern="open_mouth",
        )
        return base

    if scenario == "invalid":
        invalid_reason = random.choice(["motion", "no_contact", "unstable", "jump", "sensor_error"])
        base.update(
            hr_bpm=jitter_int(118, 3),
            rr_bpm=jitter_int(24, 2),
            temp_est_c=jitter_float(38.4, 0.05),
            invalid_reason=invalid_reason,
        )

        if invalid_reason == "motion":
            base["motion_state"] = "moving"
        elif invalid_reason == "no_contact":
            base["sqi_ppg"] = 0.22
            base["sqi_temp"] = 0.25
        elif invalid_reason == "unstable":
            base["sqi_ppg"] = 0.62
            base["sqi_rr"] = 0.55
        elif invalid_reason == "jump":
            base["temp_est_c"] = 42.5
        elif invalid_reason == "sensor_error":
            base["hr_bpm"] = None

        return base

    raise ValueError(f"unknown scenario: {scenario}")


def post_payload(base_url: str, payload: dict[str, Any]) -> None:
    url = f"{base_url.rstrip('/')}/ingest/vitals"
    response = requests.post(url, json=payload, timeout=10)

    try:
        body = response.json()
    except Exception:
        body = response.text

    print(f"[{response.status_code}] {payload['ts']} scenario payload -> {body}")
    response.raise_for_status()


def main() -> None:
    parser = argparse.ArgumentParser(description="PET BASE realtime vitals simulator")
    parser.add_argument("--base-url", default="http://127.0.0.1:8000")
    parser.add_argument("--dog-id", type=int, default=1)
    parser.add_argument("--device-id", default="dog-001")
    parser.add_argument("--interval", type=int, default=10)
    parser.add_argument(
        "--scenario",
        choices=SCENARIOS + ["cycle"],
        default="cycle",
        help="cycle이면 normal/interest/caution/danger/emergency/invalid를 순환 전송",
    )

    args = parser.parse_args()

    if args.scenario == "cycle":
        scenario_iter = itertools.cycle(SCENARIOS)
    else:
        scenario_iter = itertools.repeat(args.scenario)

    print("PET BASE simulator started")
    print(f"base_url={args.base_url}, dog_id={args.dog_id}, device_id={args.device_id}")
    print("Ctrl+C to stop")

    while True:
        scenario = next(scenario_iter)
        payload = build_payload(scenario, args.dog_id, args.device_id)
        print(f"\nscenario={scenario}")
        post_payload(args.base_url, payload)
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
