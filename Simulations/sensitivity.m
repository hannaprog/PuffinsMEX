clear; clc; close all;
run('parameters.m');

%% Settings
actuation_method = 'buoyancy';

controller_type = 'PID';
model_name = 'PID_control';

hoverTime = 180;   % 3 minutes at each depth level
startTime = 10;    % first step starts at 10 s

simTime = startTime + 4*hoverTime;

%% Nominal values
d1_nominal = d1;
m_nominal = m;
F_pos_nominal = F_pos;

%% Mission reference signal using From Workspace
t0 = startTime;
t1 = t0 + hoverTime;
t2 = t1 + hoverTime;
t3 = t2 + hoverTime;
t4 = t3 + hoverTime;

change_times  = [0 t0 t0 t1 t1 t2 t2 t3 t3 t4]';
change_values = [0 0 0.5 0.5 1.0 1.0 1.5 1.5 2.0 2.0]';

sim_in = timeseries(change_values, change_times);
sim_in = setinterpmethod(sim_in, 'zoh');

d1_values = [ ...
    0.2*d1_nominal, ...
    0.5*d1_nominal, ...
    d1_nominal, ...
    1.5*d1_nominal, ...
    2.0*d1_nominal, ...
    d1_nominal, d1_nominal, d1_nominal, d1_nominal, d1_nominal];

m_values = [ ...
    m_nominal, m_nominal, m_nominal, m_nominal, m_nominal, ...
    0.80*m_nominal, ...
    0.95*m_nominal, ...
    m_nominal, ...
    1.05*m_nominal, ...
    1.10*m_nominal];

case_names = { ...
    'd_1 -80%', 'd_1 -50%', 'd_1 nominal', 'd_1 +50%', 'd_1 +100%', ...
    'm -5%', 'm -2%', 'm nominal', 'm +2%', 'm +5%'};

nCases = length(m_values);

%% Disturbance settings
sine_amplitude = 0;
constant_amplitude = 0;
sine_frequency = 0.05;
disturbance_start_time = 0;

%% Run simulations
trackingResults = struct();

for i = 1:nCases

    simIn = Simulink.SimulationInput(model_name);

    simIn = simIn.setVariable('actuation_method', actuation_method);
    simIn = simIn.setVariable('simin', sim_in);
    simIn = simIn.setVariable('simTime', simTime);

    simIn = simIn.setVariable('sine_amplitude', sine_amplitude);
    simIn = simIn.setVariable('constant_amplitude', constant_amplitude);
    simIn = simIn.setVariable('sine_frequency', sine_frequency);
    simIn = simIn.setVariable('disturbance_start_time', disturbance_start_time);

    simIn = simIn.setVariable('d1', d1_values(i));
    simIn = simIn.setVariable('m', m_values(i));
    F_pos = 0.300 * g + m_values(i)*g;
    simIn = simIn.setVariable('F_pos', F_pos);

    simIn = simIn.setModelParameter('StopTime', num2str(simTime));

    simOut = sim(simIn);

    %% Read logged signals
    time = simOut.depth.Time(:);
    depth = simOut.depth.Data(:);
    reference = simOut.ref.Data(:);
    control_signal = simOut.control_signal.Data(:);

    %% Cumulative energy
    total_energy = simOut.energy.Data(:);
    time_energy = simOut.energy.Time(:);

    %% Tracking performance
    tracking_error = depth - reference;

    RMSE = sqrt(mean(tracking_error.^2));
    MAE = mean(abs(tracking_error));
    max_abs_error = max(abs(tracking_error));
    final_error = tracking_error(end);
    total_energy_final = total_energy(end);

    %% Store results
    trackingResults(i).controller = controller_type;
    trackingResults(i).case_name = case_names{i};

    trackingResults(i).d1_value = d1_values(i);
    trackingResults(i).m_value = m_values(i);

    trackingResults(i).time = time;
    trackingResults(i).depth = depth;
    trackingResults(i).reference = reference;
    trackingResults(i).control_signal = control_signal;

    trackingResults(i).energy = total_energy;
    trackingResults(i).time_energy = time_energy;
    trackingResults(i).total_energy = total_energy_final;

    trackingResults(i).RMSE = RMSE;
    trackingResults(i).MAE = MAE;
    trackingResults(i).MaxAbsError = max_abs_error;
    trackingResults(i).FinalError = final_error;
end

%% Summary table
summary_table = table('Size', [nCases, 7], ...
    'VariableTypes', {'string','double','double','double','double','double','double'}, ...
    'VariableNames', {'Case','RMSE','MAE','MaxAbsError','FinalError','TotalEnergy','d1Value'});

for i = 1:nCases
    summary_table.Case(i) = string(trackingResults(i).case_name);
    summary_table.RMSE(i) = trackingResults(i).RMSE;
    summary_table.MAE(i) = trackingResults(i).MAE;
    summary_table.MaxAbsError(i) = trackingResults(i).MaxAbsError;
    summary_table.FinalError(i) = trackingResults(i).FinalError;
    summary_table.TotalEnergy(i) = trackingResults(i).total_energy;
    summary_table.d1Value(i) = trackingResults(i).d1_value;
end

disp(' ')
disp('--- Sensitivity analysis summary ---')
disp(summary_table)

%% Plot: Sensitivity analysis summary
idxD1 = 1:5;
idxM  = 6:10;

figure('Color','w','Position',[100 100 1200 800]);

% 1: d1 depth tracking
subplot(2,2,1);
hold on; grid on; box on;

for i = idxD1
    plot(trackingResults(i).time, trackingResults(i).depth, ...
        'LineWidth', 1.5, ...
        'DisplayName', trackingResults(i).case_name);
end

stairs(trackingResults(1).time, trackingResults(1).reference, '--k', ...
    'LineWidth', 1.4, ...
    'DisplayName', 'Reference');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Depth tracking, d_1 variation');
legend('Location','southeast');
set(gca,'FontSize',10);

% 2: d1 cumulative energy
subplot(2,2,2);
hold on; grid on; box on;

for i = idxD1
    plot(trackingResults(i).time_energy, trackingResults(i).energy, ...
        'LineWidth', 1.5, ...
        'DisplayName', trackingResults(i).case_name);
end

xlabel('Time [s]');
ylabel('Energy [J]');
title('Cumulative energy, d_1 variation');
legend('Location','southeast');
set(gca,'FontSize',10);

% 3: mass depth tracking
subplot(2,2,3);
hold on; grid on; box on;

for i = idxM
    plot(trackingResults(i).time, trackingResults(i).depth, ...
        'LineWidth', 1.5, ...
        'DisplayName', trackingResults(i).case_name);
end

stairs(trackingResults(6).time, trackingResults(6).reference, '--k', ...
    'LineWidth', 1.4, ...
    'DisplayName', 'Reference');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Depth tracking, mass variation');
legend('Location','southeast');
set(gca,'FontSize',10);

% 4: mass cumulative energy
subplot(2,2,4);
hold on; grid on; box on;

for i = idxM
    plot(trackingResults(i).time_energy, trackingResults(i).energy, ...
        'LineWidth', 1.5, ...
        'DisplayName', trackingResults(i).case_name);
end

xlabel('Time [s]');
ylabel('Energy [J]');
title('Cumulative energy, mass variation');
legend('Location','southeast');
set(gca,'FontSize',10);