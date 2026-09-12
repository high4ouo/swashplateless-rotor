# Swashplateless Rotor

**로터 방위각에 동기된 1/rev 토크 변조 및 구동 응답 분석**

인하대학교 전기전자종합설계 · 2026<br>
팀장 최유진 · 팀원 정영우, 김호종

<p align="center">
  <img src="assets/system_overview.png" width="820" alt="System architecture linking azimuth sensing, torque modulation, motor drive, and rotor-hinge response">
</p>

*Thesis architecture. Drive-controller and rotor-response performance evaluated in simulation.*

## System

| Component | Device |
|---|---|
| Controller | NUCLEO-G474RE |
| Motor driver | X-NUCLEO-IHM08M1 |
| Motor | T-Motor MN3110 470KV |
| Azimuth sensor | AS5047P absolute encoder |

<p align="center">
  <img src="assets/bench_setup.png" width="440" alt="Bench setup integrating the motor, rotor hinge, encoder, and control boards">
</p>

## Embedded Implementation

**Azimuth → offset & wrap correction → phase compensation → 1/rev reference**

Continuous modulation phase across the 0°/360° boundary.

## Phase Compensation

A speed-dependent lookup table compensates for drive and hinge response lag.

<p align="center">
  <img src="assets/simulation_model.png" width="820" alt="Simulink torque-modulation subsystem with a speed-dependent phase-compensation lookup table">
</p>

[Model notes](docs/howToWork.md) · [Simulink files](simulation/)

## Simulation Results

**Simulink-PLECS · Two modulation amplitudes · 0°–330° phase sweep in 30° steps**

<p align="center">
  <img src="assets/moment_distribution.png" width="600" alt="Polar plot comparing mean output-moment magnitude at two torque-modulation amplitudes">
</p>

*Mean moment magnitude by azimuth. Blue: 0.01 N·m; orange: 0.02 N·m torque modulation.*

| Metric | Result |
|---|---|
| Reference / mean rotor speed | 5200 / ≈ 5230 rpm |
| Maximum absolute phase error | 4.77° |
| Mean moment magnitude at 2× modulation amplitude | 1.99× |

## Bench-top Validation

<p align="center">
  <img src="assets/bench_validation.png" width="616" alt="Physical rotor assembly during the bench test">
</p>

**PC-UART input → azimuth sensing → real-time modulation commands**

Bench validation covers rotor-angle sensing and synchronized command generation.

---

Presented at the **2026 ICROS Undergraduate Paper Competition**.

<details>
<summary>Conference poster</summary>

<a href="assets/conference_poster.png"><img src="assets/conference_poster.png" width="820" alt="ICROS conference poster"></a>

</details>
