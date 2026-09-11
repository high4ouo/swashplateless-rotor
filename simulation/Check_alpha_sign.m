clear; clc; close all;

run('Swash.m');

Model_Name = 'SwashPlateless_ESC';

% 테스트 조건
T1 = 0.01;
phi_cmd_deg = 30;
phi_cmd = deg2rad(phi_cmd_deg);

Stop_Time = 0.1;

% 세 가지 비교:
% 1) 보상 없음
% 2) alpha_sign = +1
% 3) alpha_sign = -1
test_name = ["baseline", "alpha_plus", "alpha_minus"];

alpha_table_list = {
    zeros(size(rpm_bp)), ...
    [0 20 45 70 90 108 108], ...
    [0 20 45 70 90 108 108]
};

alpha_sign_list = [1, 1, -1];

fprintf('=== Alpha sign check ===\n');

for k = 1:3

    alpha_bp_deg = alpha_table_list{k};
    alpha_bp_rad = deg2rad(alpha_bp_deg);
    alpha_sign = alpha_sign_list(k);

    simOut = sim(Model_Name, 'StopTime', num2str(Stop_Time));

    % 마지막 10% 구간 기준
    phi_data = squeeze(simOut.phi_out_sim.Data);
    idx = max(1, round(numel(phi_data)*0.9)) : numel(phi_data);

    % circular mean
    phi_out_rad = angle(mean(exp(1j*phi_data(idx))));
    phi_out_deg = mod(rad2deg(phi_out_rad), 360);

    phi_err_deg = mod(phi_out_deg - phi_cmd_deg + 180, 360) - 180;

    wrm_data = squeeze(simOut.Wrm_sim.Data);
    idx_w = max(1, round(numel(wrm_data)*0.9)) : numel(wrm_data);
    wrm_avg = mean(wrm_data(idx_w));
    rpm_avg = wrm_avg * 60/(2*pi);

    fprintf('%s: alpha_sign = %+d, rpm_avg = %.1f rpm, phi_out = %.2f deg, error = %.2f deg\n', ...
        test_name(k), alpha_sign, rpm_avg, phi_out_deg, phi_err_deg);
end