%% Sweep_param.m
clear; clc; close all;

run('Swash.m');

Model_Name = 'SwashPlateless_ESC';
Save_Filename = 'Swash_Sweep_Results.xlsx';

% Test Parameter
T1_range = 0.01 : 0.01 : 0.02;
phi_range_deg = 0 : 30 : 330;

results_matrix = [];

count = 1;
total_cases = length(T1_range) * length(phi_range_deg);

fprintf('=== SwashPlateless Parametric Sweep Started ===\n');
fprintf('Total cases to simulate: %d\n\n', total_cases);

tic;

for i = 1:length(T1_range)
    for j = 1:length(phi_range_deg)

        T1 = T1_range(i);
        phi_cmd = deg2rad(phi_range_deg(j));

        try
            simOut = sim(Model_Name, 'StopTime', num2str(Stop_Time));

            % -----------------------------
            % Mmag 추출
            % -----------------------------
            mmag_data = squeeze(simOut.Mmag_sim.Data);
            idx_m = max(1, round(numel(mmag_data)*0.9)) : numel(mmag_data);
            m_mag_val = mean(mmag_data(idx_m));

            % -----------------------------
            % phi_out 추출: circular mean 사용
            % -----------------------------
            phi_out_data = squeeze(simOut.phi_out_sim.Data);
            idx_p = max(1, round(numel(phi_out_data)*0.9)) : numel(phi_out_data);

            phi_out_val_rad = angle(mean(exp(1j*phi_out_data(idx_p))));
            phi_out_val_deg = mod(rad2deg(phi_out_val_rad), 360);

            phi_err_deg = mod(phi_out_val_deg - phi_range_deg(j) + 180, 360) - 180;

            % -----------------------------
            % W_rm / RPM 추출
            % -----------------------------
            wrm_data = squeeze(simOut.Wrm_sim.Data);
            idx_w = max(1, round(numel(wrm_data)*0.9)) : numel(wrm_data);

            wrm_avg = mean(wrm_data(idx_w));
            rpm_avg = wrm_avg * 60/(2*pi);

            % -----------------------------
            % 결과 저장
            % -----------------------------
            results_matrix(count, :) = [count, T1, phi_range_deg(j), ...
                                        rpm_avg, m_mag_val, phi_out_val_deg, phi_err_deg];

            fprintf('[%d/%d] Success: T1=%.3f, phi_cmd=%6.1f deg -> RPM=%.1f, Mmag=%.5f, phi_out=%7.2f deg, error=%7.2f deg\n', ...
                    count, total_cases, T1, phi_range_deg(j), rpm_avg, m_mag_val, phi_out_val_deg, phi_err_deg);

        catch ME
            fprintf('[%d/%d] Error at T1=%.3f, phi=%.1f: %s\n', ...
                    count, total_cases, T1, phi_range_deg(j), ME.message);

            results_matrix(count, :) = [count, T1, phi_range_deg(j), NaN, NaN, NaN, NaN];
        end

        count = count + 1;
    end
end

simulation_time = toc;

fprintf('\n=== All simulations complete! ===\n');
fprintf('Total simulation time: %.1f seconds\n', simulation_time);

FinalTable = array2table(results_matrix, ...
    'VariableNames', {'Case_No', 'T1_Nm', 'Phi_cmd_deg', ...
                      'RPM_avg', 'Mmag_avg', 'Phi_out_deg', 'Phi_error_deg'});

writetable(FinalTable, Save_Filename);

disp('Data saved successfully.');