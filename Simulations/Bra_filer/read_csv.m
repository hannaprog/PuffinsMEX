clear; clc; close all

% ===== Fil och namn =====
filnamn = "MISION24.csv";
namn    = "Mission 07";

% ===== Inställningar =====
batteryVoltage = 11.10;   % [V]
tMax = 480;               % [s]

% ===== Läs in filen =====
D = lasMissionData(filnamn, namn, batteryVoltage);

% ===== Kapa data vid tMax =====
idx = D.tid <= tMax;

D.tid               = D.tid(idx);
D.ref               = D.ref(idx);
D.depth             = D.depth(idx);
D.depthError        = D.depthError(idx);
D.pidOutput         = D.pidOutput(idx);
D.current           = D.current(idx);
D.currentForEnergy  = D.currentForEnergy(idx);

% ===== Räkna om energi efter kapning =====
D.energy_J = batteryVoltage .* cumtrapz(D.tid, D.currentForEnergy);

% ===== Beräkna total energi =====
totalEnergy_J = D.energy_J(end);

% ===== Beräkna RMSE =====
trackingError = D.depth - D.ref;
rmse_m = sqrt(mean(trackingError.^2, 'omitnan'));

% ===== Beräkna medelström, valfritt men användbart =====
meanCurrent_A = mean(D.currentForEnergy, 'omitnan');

%% Plot: Depth tracking, control signal, current and energy

figure('Color','w','Position',[100 100 1400 650]);

tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

% ==========================================================
% Plot 1: Depth reference tracking, full width
% ==========================================================
ax1 = nexttile([1 3]);
hold on; grid on; box on;

plot(D.tid, D.depth, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'Depth');

stairs(D.tid, D.ref, '--k', ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Reference');

xlabel('Time [s]');
ylabel('Depth [m]');
title('Depth reference tracking');
legend('Location','southeast');
set(gca,'FontSize',11);
xlim([0 tMax]);


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
xlim([0 tMax]);


% ==========================================================
% Plot 3: Current
% ==========================================================
ax3 = nexttile;
hold on; grid on; box on;

plot(D.tid, D.currentForEnergy, ...
    'LineWidth', 1.6);

xlabel('Time [s]');
ylabel('Current [A]');
title('Measured current');
set(gca,'FontSize',11);
xlim([0 tMax]);


% ==========================================================
% Plot 4: Cumulative energy
% ==========================================================
ax4 = nexttile;
hold on; grid on; box on;

plot(D.tid, D.energy_J, ...
    'LineWidth', 1.6);

xlabel('Time [s]');
ylabel('Energy [J]');
title('Cumulative energy consumption');
set(gca,'FontSize',11);
xlim([0 tMax]);

linkaxes([ax1 ax2 ax3 ax4], 'x');


% ==========================================================
% Skriv ut resultat i command window
% ==========================================================
fprintf('\n===== Mission summary =====\n')
fprintf('Mission: %s\n', D.namn)
fprintf('Analysed interval: 0–%.0f s\n', tMax)
fprintf('Total energy: %.2f J\n', totalEnergy_J)
fprintf('RMSE: %.4f m\n', rmse_m)
fprintf('Mean current: %.3f A\n', meanCurrent_A)


% ==========================================================
% Lokal funktion för att läsa in mission-fil
% ==========================================================
function S = lasMissionData(filnamn, namn, batteryVoltage)

    % ===== Läs in hela filen som text =====
    rader = readlines(filnamn);

    % Ta bort tomma rader
    rader = strip(rader);
    rader(rader == "") = [];

    % ===== Läs header =====
    header = split(rader(1), ",")';
    header = strtrim(header);
    header(header == "") = [];

    % Gör header-namn MATLAB-säkra och unika
    header = matlab.lang.makeValidName(header);
    header = matlab.lang.makeUniqueStrings(header);

    % ===== Läs datarader =====
    dataText = split(rader(2:end), ",");

    % Kapa till rätt antal kolumner
    dataText = dataText(:, 1:numel(header));

    % Konvertera till numerisk matris
    M = str2double(dataText);

    % Gör table
    T = array2table(M, "VariableNames", cellstr(header));

    disp("Variabler i " + filnamn + ":")
    disp(T.Properties.VariableNames')

    % ===== Plocka ut data =====
    S.namn       = namn;
    S.tid        = T.time_s;
    S.ref        = T.target_depth_m;
    S.depth      = T.depth_m;
    S.depthError = T.depth_error_m;
    S.pidOutput  = T.pid_output;
    S.current    = T.current_A;

    % ======================================================
    % Energi
    % ======================================================
    % Strömmen verkar vara negativ i loggen.
    % Därför används absolutbeloppet för energiberäkning.
    S.currentForEnergy = abs(S.current);

    % Kumulativ energi:
    % E = U * integral(I dt)
    S.energy_J = batteryVoltage .* cumtrapz(S.tid, S.currentForEnergy);

end