clear; clc; close all;
run('parameters.m');

%% Settings
actuation_method = 'buoyancy';

controller_type = 'PID';
model_name = 'PID_control';

hoverTime = 180;   % 3 minutes at each depth level
startTime = 10;    % first step starts at 10 s

simTime = startTime + 4*hoverTime;

%% Mission reference signal using From Workspace
% Mission:
% 0 m until t = 10 s
% 0.5 m for 3 minutes
% 1.0 m for 3 minutes
% 1.5 m for 3 minutes
% 2.0 m for 3 minutes

t0 = startTime;
t1 = t0 + hoverTime;
t2 = t1 + hoverTime;
t3 = t2 + hoverTime;
t4 = t3 + hoverTime;

change_times  = [0 t0 t0 t1 t1 t2 t2 t3 t3 t4]';
change_values = [0 0 0.5 0.5 1.0 1.0 1.5 1.5 2.0 2.0]';

sim_in = timeseries(change_values, change_times);

% Hold reference constant between points
sim_in = setinterpmethod(sim_in, 'zoh');

%% Disturbance settings
sine_amplitude = 0;
constant_amplitude = 0;
sine_frequency = 0.05;

%% Run simulation
simIn = Simulink.SimulationInput(model_name);

simIn = simIn.setVariable('actuation_method', actuation_method);
simIn = simIn.setVariable('simin', sim_in);
simIn = simIn.setVariable('simTime', simTime);

simIn = simIn.setVariable('sine_amplitude', sine_amplitude);
simIn = simIn.setVariable('constant_amplitude', constant_amplitude);
simIn = simIn.setVariable('sine_frequency', sine_frequency);

% No delayed disturbance in this mission simulation
simIn = simIn.setVariable('disturbance_start_time', 0);

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

%% Print key results
disp(' ')
disp('--- PID mission results ---')
fprintf('RMSE: %.4f m\n', RMSE);
fprintf('MAE: %.4f m\n', MAE);
fprintf('Max absolute error: %.4f m\n', max_abs_error);
fprintf('Final error: %.4f m\n', final_error);
fprintf('Total cumulative energy: %.2g J\n', total_energy_final);

%% Figure: Mission depth tracking, control signal and cumulative energy

figure('Color','w','Position',[100 100 1100 700]);

% Top: depth tracking
subplot(2,1,1);
hold on; grid on; box on;

plot(time, depth, 'LineWidth', 1.8, ...
    'DisplayName', 'PID depth');

stairs(time, reference, '--k', 'LineWidth', 1.6, ...
    'DisplayName', 'Reference');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Sampling mission depth tracking with PID controller');
legend('Location','southeast');
set(gca,'FontSize',11);

% Bottom: control signal and cumulative energy
subplot(2,1,2);
grid on; box on; hold on;

yyaxis left
plot(time, control_signal, 'LineWidth', 1.5, ...
    'DisplayName', 'Control signal');
ylabel('Control signal');

yyaxis right
plot(time_energy, total_energy, 'LineWidth', 1.8, ...
    'DisplayName', 'Cumulative energy');
ylabel('Cumulative energy [J]');

xlabel('Time [s]');
title(sprintf('Sampling mission control signal and cumulative energy', total_energy_final));

legend('Control signal','Cumulative energy','Location','southeast');
set(gca,'FontSize',11);