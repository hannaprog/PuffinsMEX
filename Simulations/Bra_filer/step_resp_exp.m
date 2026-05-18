clear; clc; close all

% ==========================================================
% Fil och namn
% ==========================================================
filnamn = "PUFPUF88.csv";
namn    = "Step response";

% 80 och 84 är bra och 71 är bra

% ==========================================================
% Inställningar
% ==========================================================
batteryVoltage = 11.10;   % [V]
settlingBand_m = 0.20;    % [m] Settling band: +-20 cm

% ==========================================================
% Kapa data mellan tStart och tMax
% ==========================================================
tStart = 0;      % [s]
tMax   = 200;    % [s]
tPlotMax = tMax - tStart;

% ==========================================================
% Läs in filen
% ==========================================================
D = lasMissionData(filnamn, namn, batteryVoltage);

% ==========================================================
% Kapa data
% ==========================================================
idx = D.tid >= tStart & D.tid <= tMax;

D.tid               = D.tid(idx);
D.ref               = D.ref(idx);
D.depth             = D.depth(idx);
D.depthError        = D.depthError(idx);
D.pidOutput         = D.pidOutput(idx);
D.current           = D.current(idx);
D.currentForEnergy  = D.currentForEnergy(idx);

% Flytta tiden så analyserat intervall börjar vid 0 s
D.tid = D.tid - tStart;

% ==========================================================
% Offset av djup och referens
% ==========================================================
% Behåller dina offsets här
%D.depth = D.depth + 0.1;

%D.depth = D.depth - 0.8;
%D.ref   = D.ref   - 0.8;

% ==========================================================
% Energi, RMSE och medelström för hela analyserade intervallet
% ==========================================================
D.energy_J = batteryVoltage .* cumtrapz(D.tid, D.currentForEnergy);

totalEnergy_J = D.energy_J(end);

trackingError = D.depth - D.ref;
rmse_m = sqrt(mean(trackingError.^2, 'omitnan'));

meanCurrent_A = mean(D.currentForEnergy, 'omitnan');

% ==========================================================
% Beräkna step response metrics
% ==========================================================
stepMetrics = calculateStepResponseMetrics( ...
    D.tid, D.ref, D.depth, D.currentForEnergy, batteryVoltage, settlingBand_m);

step_table = table( ...
    string(stepMetrics.Step), ...
    stepMetrics.RiseTime, ...
    stepMetrics.RMSE, ...
    stepMetrics.SettlingTime, ...
    stepMetrics.TotalEnergy, ...
    'VariableNames', {'Step','RiseTime','RMSE','SettlingTime','TotalEnergy'});

%% ==========================================================
% Plot: Step response depth tracking and control signal
% ==========================================================

figure('Color','w','Position',[100 100 1200 600]);

tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

% ==========================================================
% Plot 1: Depth reference tracking
% ==========================================================
ax1 = nexttile;
hold on; grid on; box on;

plot(D.tid, D.depth, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'Depth');

stairs(D.tid, D.ref, '--k', ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Reference');

ylabel('Depth [m]');
title('Step response depth tracking');
legend('Location','southeast');
set(gca,'FontSize',11);
xlim([0 tPlotMax]);

% ==========================================================
% Plot 2: Control signal
% ==========================================================
ax2 = nexttile;
hold on; grid on; box on;

plot(D.tid, D.pidOutput, ...
    'LineWidth', 1.6);

xlabel('Time [s]');
ylabel('Control signal');
title('Control signal');
set(gca,'FontSize',11);
xlim([0 tPlotMax]);

linkaxes([ax1 ax2], 'x');

% ==========================================================
% Skriv ut resultat i command window
% ==========================================================
fprintf('\n===== Step response summary =====\n')
fprintf('Run: %s\n', D.namn)
fprintf('Analysed interval: 0–%.0f s\n', tPlotMax)
fprintf('Detected step: %s\n', stepMetrics.Step)
fprintf('Step time: %.2f s\n', stepMetrics.StepTime)
fprintf('Rise time: %.2f s\n', stepMetrics.RiseTime)
fprintf('Settling time, +-%.2f m band: %.2f s\n', settlingBand_m, stepMetrics.SettlingTime)
fprintf('Total energy, full interval: %.2f J\n', totalEnergy_J)
fprintf('Energy, detected step interval: %.2f J\n', stepMetrics.TotalEnergy)
fprintf('RMSE, full interval: %.4f m\n', rmse_m)
fprintf('RMSE, detected step interval: %.4f m\n', stepMetrics.RMSE)
fprintf('Mean current: %.3f A\n', meanCurrent_A)

% ==========================================================
% LaTeX-tabell
% ==========================================================
% ==========================================================
% Skapa tabell med step response metrics
% ==========================================================
step_table = table( ...
    string(stepMetrics.Step), ...
    stepMetrics.RiseTime, ...
    stepMetrics.RMSE, ...
    stepMetrics.SettlingTime, ...
    stepMetrics.TotalEnergy, ...
    'VariableNames', {'Step','RiseTime','RMSE','SettlingTime','TotalEnergy'});

% ==========================================================
% LaTeX-tabell
% ==========================================================
disp(' ')
disp('--- LaTeX table: step response ---')

fprintf('\\begin{table}[H]\n');
fprintf('\\centering\n');
fprintf('\\small\n');

fprintf(['\\caption{Step response performance for the buoyancy-based actuation system. ' ...
         'The depth and reference signals were offset by the initial reference depth ' ...
         'to show the response relative to the starting depth. Settling time was defined ' ...
         'using a fixed $\\pm %.2f\\,\\mathrm{m}$ band around the reference.}\n'], settlingBand_m);

fprintf('\\label{tab:step_response_results}\n');

% Full text width table
fprintf('\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}lrrrr@{}}\n');
fprintf('\\toprule\n');

fprintf('Step & Rise time [s] & RMSE [m] & Settling time [s] & Energy [J] \\\\\n');

fprintf('\\midrule\n');

for i = 1:height(step_table)

    step_latex = char(step_table.Step(i));
    energy_latex = formatEnergyTwoSigFigs(step_table.TotalEnergy(i));

    fprintf('%s & %s & %s & %s & %s \\\\\n', ...
        step_latex, ...
        formatLatexNumber(step_table.RiseTime(i), '%.2f'), ...
        formatLatexNumber(step_table.RMSE(i), '%.3f'), ...
        formatLatexNumber(step_table.SettlingTime(i), '%.2f'), ...
        energy_latex);
end

fprintf('\\bottomrule\n');
fprintf('\\end{tabular*}\n');
fprintf('\\end{table}\n');

% ==========================================================
% Lokal funktion för att läsa in mission-fil
% ==========================================================
function S = lasMissionData(filnamn, namn, batteryVoltage)

    rader = readlines(filnamn);

    rader = strip(rader);
    rader(rader == "") = [];

    header = split(rader(1), ",")';
    header = strtrim(header);
    header(header == "") = [];

    header = matlab.lang.makeValidName(header);
    header = matlab.lang.makeUniqueStrings(header);

    dataText = split(rader(2:end), ",");

    dataText = dataText(:, 1:numel(header));

    M = str2double(dataText);

    T = array2table(M, "VariableNames", cellstr(header));

    disp("Variabler i " + filnamn + ":")
    disp(T.Properties.VariableNames')

    S.namn       = namn;
    S.tid        = T.time_s;
    S.ref        = T.target_depth_m;
    S.depth      = T.depth_m;
    S.depthError = T.depth_error_m;
    S.pidOutput  = T.pid_output;
    S.current    = T.current_A;

    % Absolutbelopp används för energi
    S.currentForEnergy = abs(S.current);

    S.energy_J = batteryVoltage .* cumtrapz(S.tid, S.currentForEnergy);

end

% ==========================================================
% Beräkna step response metrics
% ==========================================================
function M = calculateStepResponseMetrics(t, ref, depth, current, batteryVoltage, settlingBand_m)

    valid = isfinite(t) & isfinite(ref) & isfinite(depth) & isfinite(current);
    t = t(valid);
    ref = ref(valid);
    depth = depth(valid);
    current = current(valid);

    t = t(:);
    ref = ref(:);
    depth = depth(:);
    current = current(:);

    % Säkerställ att tiden är sorterad
    [t, sortIdx] = sort(t);
    ref = ref(sortIdx);
    depth = depth(sortIdx);
    current = current(sortIdx);

    % ======================================================
    % Samplingstid
    % ======================================================
    dt = median(diff(t), 'omitnan');

    if isnan(dt) || dt <= 0
        dt = 1;
    end

    % ======================================================
    % Smoothing av depth för metrics
    % ======================================================
    smoothWindow_s = 2;
    smoothWindow_N = max(3, round(smoothWindow_s / dt));
    smoothWindow_N = min(smoothWindow_N, length(depth));

    depthSmooth = movmean(depth, smoothWindow_N, 'omitnan');

    % ======================================================
    % Detektera om referensen har ett tydligt steg.
    % Om inget referenssteg hittas behandlas testet som:
    % initial depth -> final reference.
    % ======================================================
    refDiff = abs(diff(ref));
    finiteRefDiff = refDiff(isfinite(refDiff));

    if isempty(finiteRefDiff)
        maxRefDiff = 0;
    else
        maxRefDiff = max(finiteRefDiff);
    end

    stepThreshold = max(0.02, 0.25 * maxRefDiff);

    stepIdx = [];

    if maxRefDiff > 0.02
        stepIdx = find(refDiff > stepThreshold, 1, 'first');
    end

    if isempty(stepIdx)

        % Ingen tydlig ändring i referens.
        % Då antas steget börja vid första datapunkten.
        stepStartIdx = 1;
        tStep = t(stepStartIdx);
        endIdx = length(t);

        initialWindow_s = 0.5;
        initialN = max(1, round(initialWindow_s / dt));
        initialN = min(initialN, length(depth));

        depthInitial = median(depth(1:initialN), 'omitnan');

    else

        % Tydligt referenssteg hittades.
        stepStartIdx = stepIdx + 1;
        tStep = t(stepStartIdx);

        % Hitta eventuellt nästa steg i referensen
        laterStepIdx = find(refDiff(stepStartIdx:end) > stepThreshold, 1, 'first');

        if isempty(laterStepIdx)
            endIdx = length(t);
        else
            endIdx = stepStartIdx + laterStepIdx - 1;
        end

        preWindow_s = 2;
        preN = max(3, round(preWindow_s / dt));
        preRange = max(1, stepIdx - preN + 1):stepIdx;

        depthInitial = median(depthSmooth(preRange), 'omitnan');

    end

    % ======================================================
    % Slutreferens
    % ======================================================
    finalWindow_s = 3;
    finalN = max(3, round(finalWindow_s / dt));
    finalN = min(finalN, endIdx - stepStartIdx + 1);

    refAfter = median(ref(endIdx - finalN + 1:endIdx), 'omitnan');

    % ======================================================
    % Responsintervall
    % ======================================================
    respRange = stepStartIdx:endIdx;

    tResp = t(respRange);
    refResp = ref(respRange);
    depthResp = depth(respRange);
    depthSmoothResp = depthSmooth(respRange);
    currentResp = current(respRange);

    % ======================================================
    % Stegamplitud baserad på initialt djup till slutreferens
    % ======================================================
    stepAmplitude = refAfter - depthInitial;

    % ======================================================
    % Rise time: 10 % till 90 % av steget
    % ======================================================
    if abs(stepAmplitude) < eps

        riseTime = NaN;

    else

        level10 = depthInitial + 0.10 * stepAmplitude;
        level90 = depthInitial + 0.90 * stepAmplitude;

        if stepAmplitude > 0
            idx10 = find(depthSmoothResp >= level10, 1, 'first');
            idx90 = find(depthSmoothResp >= level90, 1, 'first');
        else
            idx10 = find(depthSmoothResp <= level10, 1, 'first');
            idx90 = find(depthSmoothResp <= level90, 1, 'first');
        end

        if isempty(idx10) || isempty(idx90) || idx90 < idx10
            riseTime = NaN;
        else
            riseTime = tResp(idx90) - tResp(idx10);
        end

    end

    % ======================================================
    % RMSE efter steget
    % ======================================================
    trackingError = depthResp - refResp;
    rmse = sqrt(mean(trackingError.^2, 'omitnan'));

    % ======================================================
    % Settling time: inom +-0.20 m och stannar där
    % ======================================================
    withinBand = abs(depthSmoothResp - refAfter) <= settlingBand_m;

    settlingTime = NaN;

    % Detta förhindrar att bara sista punkten räknas som settling.
    minimumSettledDuration_s = 10;

    for k = 1:length(withinBand)

        enoughTimeLeft = (tResp(end) - tResp(k)) >= minimumSettledDuration_s;

        if enoughTimeLeft && all(withinBand(k:end))
            settlingTime = tResp(k) - tStep;
            break
        end

    end

    % ======================================================
    % Energi från steget till slutet av step response-intervallet
    % ======================================================
    totalEnergy = batteryVoltage * trapz(tResp, abs(currentResp));

    % ======================================================
    % Output struct
    % ======================================================
    M.Step = sprintf('%.2f--%.2f m', depthInitial, refAfter);
    M.StepTime = tStep;
    M.RiseTime = riseTime;
    M.RMSE = rmse;
    M.SettlingTime = settlingTime;
    M.TotalEnergy = totalEnergy;

end

% ==========================================================
% Formatera tal till LaTeX-tabell
% ==========================================================
function s = formatLatexNumber(x, fmt)

    if isnan(x) || isinf(x)
        s = '--';
    else
        s = sprintf(fmt, x);
    end

end

% ==========================================================
% Formatera energi med ungefär två signifikanta siffror
% ==========================================================
function s = formatEnergyTwoSigFigs(E)

    if isnan(E) || isinf(E)
        s = '--';
        return
    end

    if abs(E) >= 1000
        s = sprintf('%.0f', round(E / 100) * 100);
    elseif abs(E) >= 100
        s = sprintf('%.0f', round(E / 10) * 10);
    elseif abs(E) >= 10
        s = sprintf('%.1f', E);
    else
        s = sprintf('%.2f', E);
    end

end