# Swashplateless Rotor

### Azimuth-Synchronized Torque Modulation on STM32G4

A swashplateless rotor project that generates a **1/rev periodic drive command synchronized with rotor azimuth**.

The project combines a real-time STM32G4 bench-top implementation with a Simulink-PLECS drive model for phase-response analysis.

**Inha University · Electrical and Electronic Engineering Capstone Design · 2026**  
**Team Lead: Yu-jin Choi (최유진)** · Team Members: Young-woo Chung (정영우), Ho-jong Kim (김호종)

<p align="center">
  <img src="assets/system_overview.png" width="820" alt="Original system architecture from the thesis, showing command input, rotor-azimuth sensing, torque modulation, the simulated drive controller, and rotor-hinge response.">
</p>

*Thesis architecture; drive and rotor-response analysis are evaluated in simulation.*

---

## System

The bench-top system measures absolute rotor azimuth and updates the synchronized modulation command in real time.

| Component | Device |
|---|---|
| MCU | STM32G474RE NUCLEO |
| Motor Driver | X-NUCLEO-IHM08M1 |
| Motor | T-Motor MN3110 470KV |
| Rotor Position Sensor | AS5047P Magnetic Absolute Encoder |

<p align="center">
  <img src="assets/bench_setup.png" width="440" alt="Physical bench setup with the MN3110 motor, red rotor hub, encoder wiring, stacked control boards, and external power supply.">
</p>

---

## Embedded Implementation

The STM32 firmware processes the rotor-angle measurement and generates the 1/rev modulation command in the following sequence.

**AS5047P rotor azimuth → zero-offset compensation → 0°/360° boundary handling → phase compensation → 1/rev cosine modulation → drive-reference update**

The encoder installation offset is compensated in firmware, and the angular boundary is handled so that the modulation phase remains continuous when the rotor passes between 359° and 0°.

Using the corrected rotor azimuth, the drive reference is updated in real time on the STM32G4.

<p align="center">
  <img src="assets/phase_lut.png" width="500" alt="Original thesis screenshot of the firmware's rotor-speed breakpoints and phase-compensation lookup table.">
</p>

*Original firmware LUT screenshot from the thesis.*

---

## Phase Compensation

A Simulink-PLECS model was constructed using the MN3110 motor parameters to analyze the response of the azimuth-synchronized periodic command.

Because the mechanical response delay changes with rotor speed, the phase-compensation angle was implemented as a speed-dependent Look-Up Table (LUT).

<p align="center">
  <img src="assets/simulation_model.png" width="820" alt="Torque-modulation subsystem in the Simulink-PLECS drive model, including the speed-dependent phase-compensation lookup table.">
</p>

*Torque-modulation subsystem from the simulation model.*

[Simulink model and supporting files](simulation/) · [Model](simulation/SwashPlateless_ESC.slx) · [Parameters](simulation/Swash.m) · [Sweep script](simulation/Sweep_param.m) · [Phase-sign check](simulation/Check_alpha_sign.m) · [Recorded sweep results](simulation/Swash_Sweep_Results.xlsx)

[Simulink 모델 이론 및 수식 설명](docs/howToWork.md)

*Archived project files for reference; a complete reproduction environment is not bundled.*

---

## Results

**Simulink-PLECS simulation results** — two modulation amplitudes, with 12 commanded phases per amplitude (0° to 330° in 30° steps).

<p align="center">
  <img src="assets/phase_tracking.png" width="820" alt="Original simulation plot comparing commanded phase and output-moment direction for modulation amplitudes of 0.01 and 0.02 N·m.">
</p>

*Angles are displayed modulo 360°: the point near 360° at a 0° command represents a small negative phase error.*

| Metric | Result |
|---|---|
| Reference rotor speed | 5200 rpm |
| Mean rotor speed | ≈ 5230 rpm |
| Maximum absolute phase error | 4.77° |
| Modulation amplitude | 2× (0.01 → 0.02 N·m) |
| Mean output-moment magnitude | 1.99× |

In simulation, the output-moment direction followed the commanded phase over the tested full-azimuth sweep.

The maximum absolute phase error was approximately 4.77°, and doubling the modulation amplitude increased the mean output-moment magnitude by approximately 1.99×.

---

## Bench-top Validation

<p align="center">
  <img src="assets/bench_validation.png" width="616" alt="Photograph from the physical bench-top test showing the rotor assembly during operation.">
</p>

The STM32G4 controller, motor driver, MN3110 motor, and AS5047P encoder were integrated into a physical bench-top system.

During motor rotation, the following embedded processing path was verified:

**PC-UART command → rotor-azimuth measurement → real-time 1/rev modulation-command generation**

The bench test focused on rotor-angle sensing and synchronized command generation, while quantitative phase-response performance was evaluated separately using the Simulink-PLECS model.

---

동일 프로젝트로 **제어로봇시스템학회 학부생 논문 경진대회**에 참가했습니다.

<details>
<summary>Conference poster · 학회 발표 포스터</summary>

<a href="assets/conference_poster.png"><img src="assets/conference_poster.png" width="820" alt="Original 2026 ICROS conference poster for the Swashplateless rotor project, including the methods, simulation results, and bench-top system."></a>

</details>
