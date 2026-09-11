clear;
clc;
close all;

%% Simulation
Stop_Time = 0.1;

%% DC link and inverter
Vdc = 22.2;
Va_rated = Vdc;
Fsw = 10000;

%% MN3110 KV470 equivalent parameters
KV = 470;
p = 7;

Kt = 60/(2*pi*KV);      % [Nm/A]

Ra = 0.0675;            % [Ohm], phase resistance approx. 0.135/2
La = 2.84e-4;           % [H], phase inductance

J = 1.7e-5;             % [kg*m^2], estimated rotor inertia
B = 1.24e-5;            % [N*m*s], estimated viscous friction

lambda_f = Kt/(1.5*p);

%% Current controller
fc_i = 300;
Wcc = 2*pi*fc_i;

Kpc = La*Wcc;
Kic = Ra*Wcc;
Kac = Kic/Kpc;

%% Current limit
Imax = 12;

%% 1/rev torque command
T0 = 0.10;
T1 = 0.01;
phi_cmd = deg2rad(30);

%% Rotor aerodynamic load approximation
W0 = 5000/60*2*pi;
KQ = T0/(W0^2);

%% Electrical angle alignment
theta_align = deg2rad(-3);

%% Optional display/filter blocks
Ff = 1000;
Wf = 2*pi*Ff;

%% Optional hinge/disk blocks
Kh = 1;
tau_h = 0.02;

fdisk = 20;
Wdisk = 2*pi*fdisk;

%% Phase compensation lookup table for 1/rev torque modulation
rpm_bp = [0 1000 2000 3000 4000 5000 6000];

alpha_bp_deg = [0 20 45 70 90 108 108];
alpha_bp_rad = deg2rad(alpha_bp_deg);

% 부호 테스트용. 일단 +1
alpha_sign = 1;