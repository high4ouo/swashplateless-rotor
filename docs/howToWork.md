# Simulink 모델 설명

[← 프로젝트 소개](../README.md) · [모델 파일](../simulation/)

**토크 변조 → 전류 제어·인버터 → 모터 회전 → 힌지 모멘트**

변조 진폭과 명령 위상을 직접 입력해 응답을 분석하는 모델입니다. 폐루프 자세 제어는 포함하지 않습니다.

## 1. 방위각 동기 토크 변조

<p align="center">
  <img src="../assets/simulation_model.png" width="850" alt="방위각 동기 토크 변조와 위상 보정 LUT">
</p>

로터 한 회전마다 토크가 한 주기 변하도록 기준값을 생성합니다.

```math
T_{ref}=T_0+T_1\cos(\theta_m-\phi_{cmd}+\alpha)
```

| 기호 | 의미 |
|---|---|
| $\theta_m$ | 현재 로터 방위각 |
| $\phi_{cmd}$ | 명령 위상 |
| $T_0$, $T_1$ | 기본 토크, 변조 진폭 |
| $\alpha$ | 회전속도에 따른 위상 보정값 |

위상 지연은 다음 LUT로 보상합니다. 모델 내부에서는 각도를 rad로 변환해 사용합니다.

| 회전속도 (rpm) | 0 | 1000 | 2000 | 3000 | 4000 | 5000 | 6000 |
|---|---|---|---|---|---|---|---|
| 보정각 (°) | 0 | 20 | 45 | 70 | 90 | 108 | 108 |

## 2. 전류 제어와 모터 구동

<p align="center">
  <img src="../assets/current_controller.png" width="850" alt="d-q 전류 제어 및 3상 전압 지령 생성 블록">
</p>

토크 상수 $K_t$로 토크 기준값을 q축 전류로 변환합니다. 실제 블록에서는 전류를 ±12 A로 제한합니다.

```math
i_{q,ref}=\frac{T_{ref}}{K_t},\qquad i_{d,ref}=0,\qquad T_m=K_t i_q
```

d-q축 전류 오차를 PI 제어하고, 좌표변환과 공통 모드 전압 주입을 거쳐 3상 전압 지령을 만듭니다. PLECS 인버터 회로에서 계산한 상전류가 다시 제어기로 전달됩니다.

<p align="center">
  <img src="../assets/inverter_model.png" width="850" alt="PLECS의 PWM 생성, 3상 인버터 및 모터 등가 상회로">
</p>

모터 회전은 토크에서 마찰과 회전 부하를 뺀 값으로 계산합니다.

```math
J\dot{\omega}_m=T_m-B\omega_m-K_Q\omega_m|\omega_m|,\qquad
\dot{\theta}_m=\omega_m
```

$J$: 관성, $B$: 점성 마찰 계수, $K_Q$: 회전 부하 계수. 계산한 방위각과 속도를 토크 변조기로 되돌립니다.

## 3. 힌지 응답과 출력 모멘트

<p align="center">
  <img src="../assets/moment_model.png" width="850" alt="힌지 지연과 출력 모멘트 계산 블록">
</p>

기본 토크를 제외한 변조 성분에 1차 지연을 적용해 힌지 응답을 근사합니다.

```math
M_h(s)=\frac{K_h}{\tau_h s+1}\bigl(T_m(s)-T_0(s)\bigr)
```

$K_h$: 힌지 이득, $\tau_h$: 응답 시정수. 힌지 응답을 방위각 방향으로 투영한 뒤 저역통과 필터를 적용해 $M_x$, $M_y$를 구합니다.

```math
M_{mag}=\sqrt{M_x^2+M_y^2},\qquad
\phi_{out}=\mathrm{atan2}(M_y,M_x)
```

## 4. 모멘트 응답

<p align="center">
  <img src="../assets/moment_distribution.png" width="600" alt="방위각별 평균 모멘트 크기를 비교한 극좌표 그래프">
</p>

변조 진폭 0.01 N·m(파랑)과 0.02 N·m(주황)의 결과입니다. 반지름은 평균 모멘트 크기를 나타냅니다.

| 논문의 시뮬레이션 결과 | 값 |
|---|---|
| 최대 절대 위상 오차 | 4.77° |
| 변조 진폭 2배에 대한 평균 모멘트 증가 | 1.99배 |

실제 장치의 로터 기울기 검증 수치가 아니라 **구동·힌지 모델의 분석 결과**입니다.
