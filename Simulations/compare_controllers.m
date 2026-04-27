clear; clc; close all;
run('parameters.m');

%% Settings
actuation_method = 'buoyancy';

controllers = {'PID', 'I-PD', 'Cascade PID'};
file_names  = {'PID_control', 'I_PD_control', 'PID_cascaded_control'};

simTime = 300;
tolerance = 0.05;      % 5 cm band
disturbance_start_time = 120;

% Disturbance cases:
% [sine_amplitude, constant_amplitude, sine_frequency]
disturbance_cases = [
    0.5 0 0.03;   % sinusoidal disturbance, low frequency
    0.5 0 0.05;   % sinusoidal disturbance, nominal frequency
    0.5 0 0.10;   % sinusoidal disturbance, higher frequency
    0   2 0.1       % constant disturbance
];

%% ============================================================
%  REFERENCE TRACKING WITHOUT DISTURBANCE
%  ============================================================

tracking_change_times  = [0 5 5 150 150 simTime]';
tracking_change_values = [0 0 0.5 0.5 3 3]';

tracking_ref = timeseries(tracking_change_values, tracking_change_times);
tracking_ref = setinterpmethod(tracking_ref, 'zoh');

stepDefs(1).Label  = "0--0.5 m";
stepDefs(1).tStart = 5;
stepDefs(1).tEnd   = 150;
stepDefs(1).y0     = 0;
stepDefs(1).yFinal = 0.5;

stepDefs(2).Label  = "0.5--3 m";
stepDefs(2).tStart = 150;
stepDefs(2).tEnd   = simTime;
stepDefs(2).y0     = 0.5;
stepDefs(2).yFinal = 3.0;

trackingResults = struct();
trackingMetrics = struct();

trackingScenarioID = 1;
trackingMetricID = 1;

for c = 1:length(controllers)

    controller_type = controllers{c};
    model_name = file_names{c};

    simIn = Simulink.SimulationInput(model_name);

    simIn = simIn.setVariable('actuation_method', actuation_method);
    simIn = simIn.setVariable('simin', tracking_ref);
    simIn = simIn.setVariable('simTime', simTime);

    simIn = simIn.setVariable('sine_amplitude', 0);
    simIn = simIn.setVariable('constant_amplitude', 0);
    simIn = simIn.setVariable('sine_frequency', 0.05);
    simIn = simIn.setVariable('disturbance_start_time', 0);

    simIn = simIn.setModelParameter('StopTime', num2str(simTime));

    simOut = sim(simIn);

    time = simOut.depth.Time(:);
    depth = simOut.depth.Data(:);
    reference = simOut.ref.Data(:);
    control_signal = simOut.control_signal.Data(:);

    total_energy = simOut.energy.Data(:);
    time_energy = simOut.energy.Time(:);

    trackingResults(trackingScenarioID).controller = controller_type;
    trackingResults(trackingScenarioID).time = time;
    trackingResults(trackingScenarioID).depth = depth;
    trackingResults(trackingScenarioID).reference = reference;
    trackingResults(trackingScenarioID).control_signal = control_signal;
    trackingResults(trackingScenarioID).energy = total_energy;
    trackingResults(trackingScenarioID).time_energy = time_energy;

    for s = 1:length(stepDefs)

        metrics = computeStepTrackingMetrics( ...
            time, depth, reference, ...
            time_energy, total_energy, ...
            stepDefs(s).tStart, stepDefs(s).tEnd, ...
            stepDefs(s).y0, stepDefs(s).yFinal, ...
            tolerance);

        trackingMetrics(trackingMetricID).Controller = controller_type;
        trackingMetrics(trackingMetricID).Step = stepDefs(s).Label;
        trackingMetrics(trackingMetricID).ReactionTime = metrics.ReactionTime;
        trackingMetrics(trackingMetricID).RiseTime = metrics.RiseTime;
        trackingMetrics(trackingMetricID).Overshoot = metrics.Overshoot;
        trackingMetrics(trackingMetricID).RMSE = metrics.RMSE;
        trackingMetrics(trackingMetricID).SettlingTime = metrics.SettlingTime;
        trackingMetrics(trackingMetricID).TotalEnergy = metrics.TotalEnergy;

        trackingMetricID = trackingMetricID + 1;
    end

    trackingScenarioID = trackingScenarioID + 1;
end

tracking_table = struct2table(trackingMetrics);

disp(' ')
disp('--- Reference tracking table ---')
disp(tracking_table)

%% ============================================================
%  DISTURBANCE REJECTION
%  ============================================================

rejection_change_times  = [0 5 5 simTime]';
rejection_change_values = [0 0 1 1]';

rejection_ref = timeseries(rejection_change_values, rejection_change_times);
rejection_ref = setinterpmethod(rejection_ref, 'zoh');

rejectionResults = struct();
rejectionMetrics = struct();

rejectionScenarioID = 1;

for c = 1:length(controllers)

    controller_type = controllers{c};
    model_name = file_names{c};

    for d = 1:size(disturbance_cases,1)

        sine_amp = disturbance_cases(d,1);
        constant_amp = disturbance_cases(d,2);
        sine_frequency_case = disturbance_cases(d,3);

        if sine_amp > 0 && constant_amp == 0
            disturbance_type = "Sinusoidal";
            disturbance_amplitude = sine_amp;
        elseif sine_amp == 0 && constant_amp > 0
            disturbance_type = "Constant";
            disturbance_amplitude = constant_amp;
        else
            disturbance_type = "Combined";
            disturbance_amplitude = NaN;
        end

        simIn = Simulink.SimulationInput(model_name);

        simIn = simIn.setVariable('actuation_method', actuation_method);
        simIn = simIn.setVariable('simin', rejection_ref);
        simIn = simIn.setVariable('simTime', simTime);

        simIn = simIn.setVariable('sine_amplitude', sine_amp);
        simIn = simIn.setVariable('constant_amplitude', constant_amp);
        simIn = simIn.setVariable('sine_frequency', sine_frequency_case);
        simIn = simIn.setVariable('disturbance_start_time', disturbance_start_time);

        simIn = simIn.setModelParameter('StopTime', num2str(simTime));

        simOut = sim(simIn);

        time = simOut.depth.Time(:);
        depth = simOut.depth.Data(:);
        reference = simOut.ref.Data(:);
        control_signal = simOut.control_signal.Data(:);

        total_energy = simOut.energy.Data(:);
        time_energy = simOut.energy.Time(:);

        rejectionResults(rejectionScenarioID).controller = controller_type;
        rejectionResults(rejectionScenarioID).disturbance_type = disturbance_type;
        rejectionResults(rejectionScenarioID).disturbance_amplitude = disturbance_amplitude;
        rejectionResults(rejectionScenarioID).sine_disturbance = sine_amp;
        rejectionResults(rejectionScenarioID).constant_disturbance = constant_amp;
        rejectionResults(rejectionScenarioID).sine_frequency = sine_frequency_case;

        rejectionResults(rejectionScenarioID).time = time;
        rejectionResults(rejectionScenarioID).depth = depth;
        rejectionResults(rejectionScenarioID).reference = reference;
        rejectionResults(rejectionScenarioID).control_signal = control_signal;
        rejectionResults(rejectionScenarioID).energy = total_energy;
        rejectionResults(rejectionScenarioID).time_energy = time_energy;

        metrics = computeDisturbanceRejectionMetrics( ...
            time, depth, reference, ...
            time_energy, total_energy, ...
            disturbance_start_time, simTime, tolerance);

        rejectionMetrics(rejectionScenarioID).Controller = controller_type;
        rejectionMetrics(rejectionScenarioID).DisturbanceType = disturbance_type;
        rejectionMetrics(rejectionScenarioID).DisturbanceAmplitude = disturbance_amplitude;
        rejectionMetrics(rejectionScenarioID).Frequency = sine_frequency_case;
        rejectionMetrics(rejectionScenarioID).PeakDeviation = metrics.PeakDeviation;
        rejectionMetrics(rejectionScenarioID).RecoveryTime = metrics.RecoveryTime;
        rejectionMetrics(rejectionScenarioID).RMSE = metrics.RMSE;
        rejectionMetrics(rejectionScenarioID).IAE = metrics.IAE;
        rejectionMetrics(rejectionScenarioID).EnergyAfterDisturbance = metrics.EnergyAfterDisturbance;

        rejectionScenarioID = rejectionScenarioID + 1;
    end
end

disturbance_table = struct2table(rejectionMetrics);

disp(' ')
disp('--- Disturbance rejection table ---')
disp(disturbance_table)

%% ============================================================
%  LATEX TABLE: REFERENCE TRACKING
%  ============================================================

disp(' ')
disp('--- LaTeX table: reference tracking ---')

fprintf('\\begin{table}[H]\n');
fprintf('\\centering\n');
fprintf('\\small\n');
fprintf('\\caption{Reference tracking performance for the buoyancy-based actuation system using PID, Cascade PID and I-PD controllers. The metrics are evaluated separately for each reference step.}\n');
fprintf('\\label{tab:tracking_results}\n');
fprintf('\\begin{tabular}{llrrrrrr}\n');
fprintf('\\toprule\n');

fprintf(['Controller & Step & ' ...
         '\\makecell{Reaction\\\\[-1mm]time [s]} & ' ...
         '\\makecell{Rise\\\\[-1mm]time [s]} & ' ...
         '\\makecell{Overshoot\\\\[-1mm][\\%%]} & ' ...
         '\\makecell{RMSE\\\\[-1mm][m]} & ' ...
         '\\makecell{Settling time\\\\[-1mm][s]} & ' ...
         '\\makecell{Energy\\\\[-1mm][J]} \\\\\n']);

fprintf('\\midrule\n');

for i = 1:height(tracking_table)

    controller_latex = char(tracking_table.Controller(i));
    controller_latex = strrep(controller_latex, '_', '\\_');

    step_latex = char(tracking_table.Step(i));
    energy_latex = formatEnergyTwoSigFigs(tracking_table.TotalEnergy(i));

    printControllerRowColor(controller_latex);

    fprintf('%s & %s & %.2f & %.2f & %.1f & %.3f & %.2f & %s \\\\\n', ...
        controller_latex, ...
        step_latex, ...
        tracking_table.ReactionTime(i), ...
        tracking_table.RiseTime(i), ...
        tracking_table.Overshoot(i), ...
        tracking_table.RMSE(i), ...
        tracking_table.SettlingTime(i), ...
        energy_latex);
end

fprintf('\\bottomrule\n');
fprintf('\\end{tabular}\n');
fprintf('\\end{table}\n');

%% ============================================================
%  LATEX TABLE: DISTURBANCE REJECTION - COMPACT
%  ============================================================

disp(' ')
disp('--- LaTeX table: compact disturbance rejection ---')

fprintf('\\begin{table}[H]\n');
fprintf('\\centering\n');
fprintf('\\small\n');
fprintf('\\caption{Disturbance rejection performance for the buoyancy-based actuation system using PID, Cascade PID and I-PD controllers.}\n');
fprintf('\\label{tab:disturbance_rejection_results}\n');
fprintf('\\begin{tabular}{llrrrrr}\n');
fprintf('\\toprule\n');

fprintf(['Controller & ' ...
         '\\makecell{Disturbance\\\\Type} & ' ...
         '\\makecell{Amplitude\\\\[-1mm][N]} & ' ...
         '\\makecell{Frequency\\\\[-1mm][Hz]} & ' ...
         '\\makecell{Peak dev.\\\\[-1mm][m]} & ' ...
         '\\makecell{RMSE\\\\[-1mm][m]} & ' ...
         '\\makecell{Energy\\\\[-1mm][J]} \\\\\n']);

fprintf('\\midrule\n');

for i = 1:height(disturbance_table)

    controller_latex = char(disturbance_table.Controller(i));
    controller_latex = strrep(controller_latex, '_', '\\_');

    disturbance_latex = char(disturbance_table.DisturbanceType(i));

    energy_latex = formatEnergyTwoSigFigs(disturbance_table.EnergyAfterDisturbance(i));

    % Row color depending on controller
    if contains(controller_latex, 'Cascade PID')
        fprintf('\\rowcolor{gray!15} ');
    elseif contains(controller_latex, 'I-PD') || contains(controller_latex, 'I\\_PD')
        fprintf('\\rowcolor{blue!8} ');
    elseif strcmp(controller_latex, 'PID')
        fprintf('\\rowcolor{green!10} ');
    end

    fprintf('%s & %s & %.2f & %.2f & %.3f & %.3f & %s \\\\\n', ...
        controller_latex, ...
        disturbance_latex, ...
        disturbance_table.DisturbanceAmplitude(i), ...
        disturbance_table.Frequency(i), ...
        disturbance_table.PeakDeviation(i), ...
        disturbance_table.RMSE(i), ...
        energy_latex);
end

fprintf('\\bottomrule\n');
fprintf('\\end{tabular}\n');
fprintf('\\end{table}\n');
%% ============================================================
%  PLOTS
%  ============================================================

%% Plot 1: Reference tracking and control signal
figure('Color','w','Position',[100 100 1200 420]);

subplot(1,2,1);
hold on; grid on; box on;

for i = 1:length(trackingResults)
    plot(trackingResults(i).time, trackingResults(i).depth, ...
        'LineWidth', 1.8, ...
        'DisplayName', char(trackingResults(i).controller));
end

stairs(trackingResults(1).time, trackingResults(1).reference, '--k', ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Reference');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Depth reference tracking');
legend('Location','southeast');
set(gca,'FontSize',11);

subplot(1,2,2);
hold on; grid on; box on;

for i = 1:length(trackingResults)
    plot(trackingResults(i).time, trackingResults(i).control_signal, ...
        'LineWidth', 1.8, ...
        'DisplayName', char(trackingResults(i).controller));
end

xlabel('Time [s]');
ylabel('Control signal');
title('Control signal during reference tracking');
legend('Location','southeast');
set(gca,'FontSize',11);

%% Plot 2: Disturbance rejection cases
figure('Color','w','Position',[100 100 1200 800]);

freqs = [0.03 0.05 0.10];

for f = 1:length(freqs)

    subplot(2,2,f);
    hold on; grid on; box on;

    current_freq = freqs(f);

    for i = 1:length(rejectionResults)
        if rejectionResults(i).sine_disturbance > 0 && ...
           rejectionResults(i).constant_disturbance == 0 && ...
           abs(rejectionResults(i).sine_frequency - current_freq) < 1e-9

            plot(rejectionResults(i).time, rejectionResults(i).depth, ...
                'LineWidth', 1.8, ...
                'DisplayName', char(rejectionResults(i).controller));
        end
    end

    idx = find([rejectionResults.sine_disturbance] > 0 & ...
               [rejectionResults.constant_disturbance] == 0 & ...
               abs([rejectionResults.sine_frequency] - current_freq) < 1e-9, 1);

    if ~isempty(idx)
        stairs(rejectionResults(idx).time, rejectionResults(idx).reference, '--k', ...
            'LineWidth', 1.5, ...
            'DisplayName', 'Reference');
    end

    xline(disturbance_start_time, '--r', 'Disturbance applied', ...
        'LabelVerticalAlignment','bottom');

    xlabel('Time [s]');
    ylabel('Depth [m]');
    title(sprintf('Sinusoidal disturbance: A = 0.5 N, f = %.2f Hz', current_freq));
    legend('Location','southeast');
    set(gca,'FontSize',10);
end

subplot(2,2,4);
hold on; grid on; box on;

for i = 1:length(rejectionResults)
    if rejectionResults(i).sine_disturbance == 0 && ...
       rejectionResults(i).constant_disturbance > 0

        plot(rejectionResults(i).time, rejectionResults(i).depth, ...
            'LineWidth', 1.8, ...
            'DisplayName', char(rejectionResults(i).controller));
    end
end

idxConst = find([rejectionResults.sine_disturbance] == 0 & ...
                [rejectionResults.constant_disturbance] > 0, 1);

if ~isempty(idxConst)
    stairs(rejectionResults(idxConst).time, rejectionResults(idxConst).reference, '--k', ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Reference');
end

xline(disturbance_start_time, '--r', 'Disturbance applied', ...
    'LabelVerticalAlignment','bottom');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Constant disturbance: A = 2 N');
legend('Location','southeast');
set(gca,'FontSize',10);

%% Plot 3: Energy during reference tracking
figure('Color','w','Position',[100 100 1100 420]);
hold on; grid on; box on;

for i = 1:length(trackingResults)
    plot(trackingResults(i).time_energy, trackingResults(i).energy, ...
        'LineWidth', 1.8, ...
        'DisplayName', char(trackingResults(i).controller));
end

xlabel('Time [s]');
ylabel('Energy [J]');
title('Energy during reference tracking');
legend('Location','northeast');
set(gca,'FontSize',11);

%% ============================================================
%  LOCAL FUNCTIONS
%  ============================================================

function metrics = computeStepTrackingMetrics(time, depth, reference, ...
                                              time_energy, energy, ...
                                              tStart, tEnd, ...
                                              y0, yFinal, tol)

    idx = time >= tStart & time <= tEnd;

    t = time(idx);
    y = depth(idx);
    r = reference(idx);

    if isempty(t)
        metrics.ReactionTime = NaN;
        metrics.RiseTime = NaN;
        metrics.Overshoot = NaN;
        metrics.RMSE = NaN;
        metrics.SettlingTime = NaN;
        metrics.TotalEnergy = NaN;
        return;
    end

    amp = yFinal - y0;

    metrics.ReactionTime = computeReactionTime(t, y, tStart, y0, amp);
    metrics.RiseTime = computeRiseTime(t, y, y0, yFinal);
    metrics.Overshoot = computeOvershoot(y, y0, yFinal);
    metrics.RMSE = sqrt(mean((y - r).^2));
    metrics.SettlingTime = computeSettlingTimeAfterEvent(t, y, tStart, yFinal, tol);

    idxE = time_energy >= tStart & time_energy <= tEnd;
    E = energy(idxE);

    if numel(E) >= 2
        metrics.TotalEnergy = E(end) - E(1);
    else
        metrics.TotalEnergy = NaN;
    end
end

function metrics = computeDisturbanceRejectionMetrics(time, depth, reference, ...
                                                      time_energy, energy, ...
                                                      disturbance_start_time, ...
                                                      tEnd, tol)

    idx = time >= disturbance_start_time & time <= tEnd;

    t = time(idx);
    y = depth(idx);
    r = reference(idx);

    if isempty(t)
        metrics.PeakDeviation = NaN;
        metrics.RecoveryTime = NaN;
        metrics.RMSE = NaN;
        metrics.IAE = NaN;
        metrics.EnergyAfterDisturbance = NaN;
        return;
    end

    error = y - r;

    metrics.PeakDeviation = max(abs(error));
    metrics.RMSE = sqrt(mean(error.^2));
    metrics.IAE = trapz(t, abs(error));

    final_reference = r(end);
    metrics.RecoveryTime = computeSettlingTimeAfterEvent( ...
        t, y, disturbance_start_time, final_reference, tol);

    idxE = time_energy >= disturbance_start_time & time_energy <= tEnd;
    E = energy(idxE);

    if numel(E) >= 2
        metrics.EnergyAfterDisturbance = E(end) - E(1);
    else
        metrics.EnergyAfterDisturbance = NaN;
    end
end

function reaction_time = computeReactionTime(t, y, tStart, y0, amp)

    if abs(amp) < eps
        reaction_time = NaN;
        return;
    end

    threshold = y0 + 0.02 * amp;

    if amp > 0
        idx = find(y >= threshold, 1, 'first');
    else
        idx = find(y <= threshold, 1, 'first');
    end

    if isempty(idx)
        reaction_time = NaN;
    else
        reaction_time = t(idx) - tStart;
    end
end

function rise_time = computeRiseTime(t, y, y0, yFinal)

    amp = yFinal - y0;

    if abs(amp) < eps
        rise_time = NaN;
        return;
    end

    y10 = y0 + 0.10 * amp;
    y90 = y0 + 0.90 * amp;

    if amp > 0
        idx10 = find(y >= y10, 1, 'first');
        idx90 = find(y >= y90, 1, 'first');
    else
        idx10 = find(y <= y10, 1, 'first');
        idx90 = find(y <= y90, 1, 'first');
    end

    if isempty(idx10) || isempty(idx90) || idx90 < idx10
        rise_time = NaN;
    else
        rise_time = t(idx90) - t(idx10);
    end
end

function overshoot = computeOvershoot(y, y0, yFinal)

    amp = yFinal - y0;

    if abs(amp) < eps
        overshoot = NaN;
        return;
    end

    if amp > 0
        peak = max(y);
        overshoot = max(0, peak - yFinal) / abs(amp) * 100;
    else
        valley = min(y);
        overshoot = max(0, yFinal - valley) / abs(amp) * 100;
    end
end

function settling_time = computeSettlingTimeAfterEvent(t, y, event_time, yFinal, tol)

    outside_band = abs(y - yFinal) > tol;

    last_outside = find(outside_band, 1, 'last');

    if isempty(last_outside)
        settling_time = 0;
    elseif last_outside == length(t)
        settling_time = NaN;
    else
        settling_time = t(last_outside + 1) - event_time;
    end
end

function energy_str = formatEnergyTwoSigFigs(E)

    if isnan(E)
        energy_str = 'NaN';
        return;
    end

    if E == 0
        energy_str = '0';
        return;
    end

    rounded_E = round(E, 1 - floor(log10(abs(E))));

    if abs(rounded_E) >= 100
        energy_str = sprintf('%.0f', rounded_E);
    elseif abs(rounded_E) >= 10
        energy_str = sprintf('%.1f', rounded_E);
    elseif abs(rounded_E) >= 1
        energy_str = sprintf('%.2f', rounded_E);
    else
        energy_str = sprintf('%.3f', rounded_E);
    end
end

function printControllerRowColor(controller_latex)

    if contains(controller_latex, 'Cascade PID')
        fprintf('\\rowcolor{gray!15} ');
    elseif contains(controller_latex, 'I-PD') || contains(controller_latex, 'I\\_PD')
        fprintf('\\rowcolor{blue!8} ');
    elseif strcmp(controller_latex, 'PID')
        fprintf('\\rowcolor{green!10} ');
    end
end