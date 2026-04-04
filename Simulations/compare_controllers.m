clear; clc; close all;
run('parameters.m');

%% Settings
actuation_method = 'buoyancy';
controllers = {'PID', 'Cascade PID', 'I\_PD'};
file_names   = {'non_Cascaded_PID', 'Cascaded_PID', 'non_Cascaded_I_PD'};

% Each row:
% [sine_amplitude, constant_amplitude]
disturbances = [
    0 0;   % no disturbance
    1 0;   % sinusoidal disturbance
    0 2    % constant disturbance
];

simTime = 100;
z_ref = 3;
tolerance = 0.05;      % 5 cm band for settling time
sine_frequency = 0.05; % Hz

results = struct();
scenarioID = 1;

%% Run simulations
for c = 1:length(controllers)
    controller_type = controllers{c};
    model_name = file_names{c};

    for d = 1:size(disturbances,1)
        sine_amp = disturbances(d,1);
        constant_amp = disturbances(d,2);

        simIn = Simulink.SimulationInput(model_name);
        simIn = simIn.setVariable('actuation_method', actuation_method);
        simIn = simIn.setVariable('z_ref', z_ref);
        simIn = simIn.setVariable('simTime', simTime);

        % Disturbance parameters
        simIn = simIn.setVariable('sine_amplitude', sine_amp);
        simIn = simIn.setVariable('constant_amplitude', constant_amp);
        simIn = simIn.setVariable('sine_frequency', sine_frequency);

        % Stop time
        simIn = simIn.setModelParameter('StopTime', num2str(simTime));

        % Run simulation
        simOut = sim(simIn);

        %% Read logged signals
        depth = simOut.depth.Data(:);
        time = simOut.depth.Time(:);
        reference = simOut.ref.Data(:);
        control_signal = simOut.control_signal.Data(:);

        %% Performance metrics
        control_effort = trapz(time, control_signal.^2);
        rmse = sqrt(mean((depth - reference).^2));

        % Overshoot in percent
        overshoot = max(depth) - z_ref;
        overshoot = 100 * overshoot / z_ref;

        settling_time = computeSettlingTimeSingle(time, depth, z_ref, tolerance);

        %% Disturbance type
        if sine_amp == 0 && constant_amp == 0
            disturbance_type = "None";
            disturbance_amplitude = 0;
        elseif sine_amp > 0 && constant_amp == 0
            disturbance_type = "Sinusoidal";
            disturbance_amplitude = sine_amp;
        elseif sine_amp == 0 && constant_amp > 0
            disturbance_type = "Constant";
            disturbance_amplitude = constant_amp;
        else
            disturbance_type = "Combined";
            disturbance_amplitude = NaN;
        end

        %% Store results
        results(scenarioID).actuation = actuation_method;
        results(scenarioID).controller = controller_type;
        results(scenarioID).disturbance_type = disturbance_type;
        results(scenarioID).disturbance_amplitude = disturbance_amplitude;
        results(scenarioID).sine_disturbance = sine_amp;
        results(scenarioID).constant_disturbance = constant_amp;
        results(scenarioID).time = time;
        results(scenarioID).depth = depth;
        results(scenarioID).reference = reference;
        results(scenarioID).control_signal = control_signal;
        results(scenarioID).RMSE = rmse;
        results(scenarioID).Overshoot = overshoot;
        results(scenarioID).SettlingTime = settling_time;
        results(scenarioID).ControlEffort = control_effort;
        results(scenarioID).sine_frequency = sine_frequency;

        scenarioID = scenarioID + 1;
    end
end

%% Create summary table
nScenarios = length(results);

summary_table = table('Size', [nScenarios, 8], ...
    'VariableTypes', {'string','string','string','double','double','double','double','double'}, ...
    'VariableNames', {'Actuation','Controller','DisturbanceType', ...
                      'DisturbanceAmplitude','RMSE','Overshoot','SettlingTime','ControlEffort'});

for i = 1:nScenarios
    summary_table.Actuation(i)            = string(results(i).actuation);
    summary_table.Controller(i)           = string(results(i).controller);
    summary_table.DisturbanceType(i)      = string(results(i).disturbance_type);
    summary_table.DisturbanceAmplitude(i) = results(i).disturbance_amplitude;
    summary_table.RMSE(i)                 = results(i).RMSE;
    summary_table.Overshoot(i)            = results(i).Overshoot;
    summary_table.SettlingTime(i)         = results(i).SettlingTime;
    summary_table.ControlEffort(i)        = results(i).ControlEffort;
end

disp(' ')
disp('--- Summary table ---')
disp(summary_table)

%% LaTeX table export
disp(' ')
disp('--- LaTeX table ---')

fprintf('\\begin{table}[htbp]\n');
fprintf('\\centering\n');
fprintf('\\caption{Summary of simulation results for different controllers and disturbance scenarios.}\n');
fprintf('\\label{tab:summary_results}\n');
fprintf('\\begin{tabular}{llrrrrr}\n');
fprintf('\\toprule\n');
fprintf('Controller & \\makecell{Disturbance\\\\Type} & \\makecell{Amplitude\\\\[-1mm][N]} & \\makecell{RMSE\\\\[-1mm][m]} & \\makecell{Overshoot\\\\[-1mm][\\%%]} & \\makecell{Settling time\\\\[-1mm][s]} & \\makecell{Control effort\\\\[-1mm][\(u^2\) s]} \\\\\n');
fprintf('\\midrule\n');

for i = 1:height(summary_table)
    controller_latex = char(summary_table.Controller(i));
    controller_latex = strrep(controller_latex, '_', '\_');

    if contains(controller_latex, 'Cascade PID')
        fprintf('\\rowcolor{gray!15} ');
    elseif contains(controller_latex, 'I\\_PD')
        fprintf('\\rowcolor{blue!8} ');
    elseif contains(controller_latex, 'PID')
        fprintf('\\rowcolor{green!10} ');
    end

    fprintf('%s & %s & %.2f & %.3f & %.2f & %.3f & %.3f \\\\\n', ...
        controller_latex, ...
        char(summary_table.DisturbanceType(i)), ...
        summary_table.DisturbanceAmplitude(i), ...
        summary_table.RMSE(i), ...
        summary_table.Overshoot(i), ...
        summary_table.SettlingTime(i), ...
        summary_table.ControlEffort(i));
end

fprintf('\\bottomrule\n');
fprintf('\\end{tabular}\n');
fprintf('\\end{table}\n');


%% Plot: step response and control signal
figure('Color','w','Position',[100 100 1100 420]);

% Vänster: step response utan störning
subplot(1,2,1);
hold on; grid on; box on;

for i = 1:length(results)
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).depth, 'LineWidth', 1.8, ...
            'DisplayName', char(results(i).controller));
    end
end

for i = 1:length(results)
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).reference, '--k', 'LineWidth', 1.5, ...
            'DisplayName', 'Reference');
        break
    end
end

xlabel('Time [s]');
ylabel('Depth [m]');
title('Step response without disturbance');
legend('Location','best');
set(gca,'FontSize',11);

% Höger: styrsignal utan störning
subplot(1,2,2);
hold on; grid on; box on;

for i = 1:length(results)
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).control_signal, 'LineWidth', 1.8, ...
            'DisplayName', char(results(i).controller));
    end
end

xlabel('Time [s]');
ylabel('Control signal');
title('Control signal without disturbance');
legend('Location','best');
set(gca,'FontSize',11);

%% Plot 2: one subplot per disturbance case
figure('Color','w','Position',[100 100 1100 420]);

% Vänster: sinus disturbance
subplot(1,2,1);
hold on; grid on; box on;

for i = 1:length(results)
    if results(i).sine_disturbance > 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).depth, 'LineWidth', 1.8, ...
            'DisplayName', char(results(i).controller));
    end
end

% Referens
for i = 1:length(results)
    if results(i).sine_disturbance > 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).reference, '--k', 'LineWidth', 1.5, ...
            'DisplayName', 'Reference');
        break
    end
end

xlabel('Time [s]');
ylabel('Depth [m]');
title(sprintf('Sinusoidal disturbance (A = %.1f, f = %.2f Hz)', ...
    results(find([results.sine_disturbance] > 0 & [results.constant_disturbance] == 0,1)).sine_disturbance, ...
    results(find([results.sine_disturbance] > 0 & [results.constant_disturbance] == 0,1)).sine_frequency));
legend('Location','best');
set(gca,'FontSize',11);

% Höger: constant disturbance
subplot(1,2,2);
hold on; grid on; box on;

for i = 1:length(results)
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance > 0
        plot(results(i).time, results(i).depth, 'LineWidth', 1.8, ...
            'DisplayName', char(results(i).controller));
    end
end

% Referens
for i = 1:length(results)
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance > 0
        plot(results(i).time, results(i).reference, '--k', 'LineWidth', 1.5, ...
            'DisplayName', 'Reference');
        break
    end
end

xlabel('Time [s]');
ylabel('Depth [m]');
title(sprintf('Constant disturbance (A = %.1f) applied at t = 40s', ...
    results(find([results.sine_disturbance] == 0 & [results.constant_disturbance] > 0,1)).constant_disturbance));
legend('Location','best');
set(gca,'FontSize',11);
