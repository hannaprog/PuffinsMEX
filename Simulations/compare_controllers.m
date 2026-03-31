clear; clc; close all;
run('parameters.m');

%% Inställningar
actuation_method = 'buoyancy';
controllers = {'PID', 'Cascade PID', 'I_PD'};
file_names = {'non_Cascaded_PID', 'Cascaded_PID', 'non_Cascaded_I_PD'};

% Format per rad:
% [sine_amplitude, constant_amplitude]
disturbances = [
    0 0;   % ingen störning
    1 0;   % sinus-störning
    0 2    % konstant störning
];

simTime = 60;
z_ref = 3;
tolerance = 0.05;      % 5 cm band för settling time
sine_frequency = 0.05; % Hz

results = struct();
scenarioID = 1;

%% Kör simuleringar
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

        % Disturbance-parametrar
        simIn = simIn.setVariable('sine_amplitude', sine_amp);
        simIn = simIn.setVariable('constant_amplitude', constant_amp);
        simIn = simIn.setVariable('sine_frequency', sine_frequency);

        % Stopptid
        simIn = simIn.setModelParameter('StopTime', num2str(simTime));

        % Kör simulering
        simOut = sim(simIn);

        % Hämtar loggade signaler
        depth = simOut.depth.Data(:);
        time = simOut.depth.Time(:);
        reference = simOut.ref.Data(:);
        control_signal = simOut.control_signal.Data(:);

        %% Prestandamått
        control_effort = trapz(time, abs(control_signal).^2);
        rmse = sqrt(mean((depth - reference).^2));

        overshoot = max(depth - reference);
        if overshoot < 0
            overshoot = 0;
        end

        settling_time = computeSettlingTimeSingle(time, depth, z_ref, tolerance);

        %% Disturbance-typ som text
        if sine_amp == 0 && constant_amp == 0
            disturbance_type = "None";
        elseif sine_amp > 0 && constant_amp == 0
            disturbance_type = "Sinusoidal";
        elseif sine_amp == 0 && constant_amp > 0
            disturbance_type = "Constant";
        else
            disturbance_type = "Combined";
        end

        %% Spara resultat
        results(scenarioID).actuation = actuation_method;
        results(scenarioID).controller = controller_type;
        results(scenarioID).disturbance_type = disturbance_type;
        results(scenarioID).sine_disturbance = sine_amp;
        results(scenarioID).constant_disturbance = constant_amp;
        results(scenarioID).sine_frequency = sine_frequency;
        results(scenarioID).time = time;
        results(scenarioID).depth = depth;
        results(scenarioID).reference = reference;
        results(scenarioID).control_signal = control_signal;
        results(scenarioID).RMSE = rmse;
        results(scenarioID).Overshoot = overshoot;
        results(scenarioID).SettlingTime = settling_time;
        results(scenarioID).ControlEffort = control_effort;

        scenarioID = scenarioID + 1;
    end
end

%% Skapa resultattabell
nScenarios = length(results);

summary_table = table('Size', [nScenarios, 9], ...
    'VariableTypes', {'string','string','string','double','double','double','double','double','double'}, ...
    'VariableNames', {'Actuation','Controller','DisturbanceType', ...
                      'SineAmplitude','ConstantAmplitude','RMSE','Overshoot','SettlingTime','ControlEffort'});

for i = 1:nScenarios
    summary_table.Actuation(i) = string(results(i).actuation);
    summary_table.Controller(i) = string(results(i).controller);
    summary_table.DisturbanceType(i) = string(results(i).disturbance_type);
    summary_table.SineAmplitude(i) = results(i).sine_disturbance;
    summary_table.ConstantAmplitude(i) = results(i).constant_disturbance;
    summary_table.RMSE(i) = results(i).RMSE;
    summary_table.Overshoot(i) = results(i).Overshoot;
    summary_table.SettlingTime(i) = results(i).SettlingTime;
    summary_table.ControlEffort(i) = results(i).ControlEffort;
end

disp(' ')
disp('--- Summary table ---')
disp(summary_table)

%% Plot 1: utan disturbance
figure;
hold on; grid on;

for i = 1:nScenarios
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).depth, 'LineWidth', 1.8, ...
            'DisplayName', char(results(i).controller));
    end
end

plot(results(1).time, z_ref*ones(size(results(1).time)), '--k', ...
    'LineWidth', 1.5, 'DisplayName', 'Reference');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Depth response without disturbance');
legend('Location', 'best');

%% Plot 2: ett subplot per disturbancefall
figure;

for d = 1:size(disturbances,1)
    subplot(size(disturbances,1),1,d);
    hold on; grid on;

    current_sine = disturbances(d,1);
    current_constant = disturbances(d,2);

    for i = 1:nScenarios
        if results(i).sine_disturbance == current_sine && ...
           results(i).constant_disturbance == current_constant

            plot(results(i).time, results(i).depth, 'LineWidth', 1.8, ...
                'DisplayName', char(results(i).controller));
        end
    end

    plot(results(1).time, z_ref*ones(size(results(1).time)), '--k', ...
        'LineWidth', 1.2, 'DisplayName', 'Reference');

    xlabel('Time [s]');
    ylabel('Depth [m]');

    if current_sine == 0 && current_constant == 0
        title('No disturbance');
    elseif current_sine > 0 && current_constant == 0
        title(sprintf('Sinusoidal disturbance: A = %.1f, f = %.2f Hz', ...
            current_sine, sine_frequency));
    elseif current_sine == 0 && current_constant > 0
        title(sprintf('Constant disturbance: A = %.1f', current_constant));
    else
        title(sprintf('Combined disturbance: sine = %.1f, constant = %.1f', ...
            current_sine, current_constant));
    end

    legend('Location', 'best');
end

%% Plot 3: styrsignaler utan disturbance
figure;
hold on; grid on;

for i = 1:nScenarios
    if results(i).sine_disturbance == 0 && results(i).constant_disturbance == 0
        plot(results(i).time, results(i).control_signal, 'LineWidth', 1.8, ...
            'DisplayName', char(results(i).controller));
    end
end

xlabel('Time [s]');
ylabel('Control signal');
title('Control signals without disturbance');
legend('Location', 'best');