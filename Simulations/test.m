clear; clc;

%% PARAMETRAR - GRUNDMODELL
% Farkost
m = 3;                      % massa (kg)
g = 9.81;                   % gravitation (m/s^2)
rho = 1000;                 % vattendensitet (kg/m^3)

% Buoyancy
F_pos = 2.94 + m*g;               % positiv flytkraft vid tom tank (N)
V_max = 0.0005;             % max volym (m^3) = 500 ml
V_dot_max = 0.001;

% Aktuator (stepper + lead screw + syringe)
k_m = 5;                   % motor konstant (rad/s per styr信号)
p = 0.002;                  % ledskruv stigning (m/varv)
d = 0.1;                    % syringe diameter (m)
A = pi*(d/2)^2;             % syringe area (m^2)
A_utlopp = pi*(0.01/2)^2;

% Dynamik
d1 = 5;                     % linjär dragkoefficient (N/(m/s))
m_a = 2.5;  % added mass
C_d = 1.0;
A_cross = 0.07;
motor_torque = 0.65;
P_atm = 101325;             % Atmosfärstryck (Pa)​
F_motor_max = 2*pi*motor_torque/p;           % Max kraft från motor/ledskruv (N)
R_flow = 1e5;               % Flödesmotstånd (Pa·s/m³)

% PID
Kp = 10;
Ki = 0.1% 0.1;
Kd = 10%20;

%% SIMULERING
dt = 0.01;
T = 120;
N = T/dt;

% Tillstånd
z = 0;                      % djup (m)
w = 0;                      % hastighet (m/s)
V = 0;                      % volym i syringe (m^3)

% PID tillstånd
z_ref = 0;
e_int = 0;
e_prev = 0;

% Loggning
z_log = zeros(N,1);
w_log = zeros(N,1);
V_log = zeros(N,1);
u_log = zeros(N,1);
Vdot_log = zeros(N,1);
drag_log = zeros(N,1);

%% HUVUDLOOP
for i = 1:N
    z_ref = 3;
    % --- PID ---
    e = z_ref - z;
    e_int = e_int + e*dt;
    e_der = (e - e_prev)/dt;
    
    u = Kp*e + Ki*e_int + Kd*e_der;
    max_u = 1e-4/k_m/p/A;
    u = max(min(u, max_u), -max_u)     % Saturera styrsignal
    
    e_prev = e;
    
    % --- Aktuator (enkel modell) ---
    V_dot = k_m * u * p * A;        % Flöde in/ur syringe

    % % % Hydrostatiskt tryck på djup z
    P_hydro = rho * g * z + P_atm;
    
    % % Tryck som motorn kan generera
    F_motor = F_motor_max * u;  % 0.6 = verkningsgrad
    P_motor = F_motor / A;
    % 
    % Begränsa flöde baserat på tryckskillnad
    if P_motor > P_hydro && u > 0  % Pumpa in vatten
        %V_dot = V_dot * (1 - min(1, (P_hydro - P_atm) / (P_motor - P_atm)));
    elseif u <= 0  % Pumpa ut vatten (lättare på djup)
        V_dot = V_dot;
    else
        V_dot = 0;
    end

    %Strömningsmotstånd i slangar och ventiler
    delta_P_required = R_flow * abs(V_dot);
    if abs(P_motor - P_hydro) < delta_P_required
        V_dot = 0;  % Inte tillräckligt med tryck för att övervinna motståndet
    end
    V = V + V_dot * dt;
    V = max(min(V, V_max), 0);      % Begränsa volym; 
    
    % --- Buoyancy ---
    F_b = rho*g*V + m*g - F_pos;    % Netto flytkraft (positiv = uppåt)
    
    % --- Hydrodynamik ---
    D = 0.5 * rho * C_d * A_cross * abs(w) * w;
    
    % --- Rörelseekvation ---
    F_net = F_b - D;
    m_eff = m + m_a;
    w_dot = F_net / m_eff;              % acceleration
    w = w + w_dot * dt;
    
    % --- Ythantering ---
    if z <= 0 && w < 0
        w = 0;
        z = 0;
        %V = V_innan;
    end
    
    % --- Uppdatera position ---
    z = z + w * dt;
    z = max(z, 0);
    
    % --- Logga ---
    z_log(i) = z;
    w_log(i) = w;
    V_log(i) = V * 1e6;             % Konvertera till ml
    Vdot_log(i) = V_dot * 1e6; 
    u_log(i) = u;
    drag_log(i) = D;
end

%% PLOTTA
figure;

subplot(3,1,1)
plot((1:N)*dt, z_log, 'b-', 'LineWidth', 1.5)
hold on
plot((1:N)*dt, z_ref*ones(N,1))
ylabel('Djup z (m)')
legend('Aktuell', 'Referens')
grid on
title('AUV djupreglering')

subplot(3,1,2)
plot((1:N)*dt, V_log, 'b-', 'LineWidth', 1.5)
ylabel('Volym (ml)')
grid on
title('Ballastvolym')

subplot(3,1,3)
plot((1:N)*dt, u_log, 'b-', 'LineWidth', 1.5)
ylabel('Styrsignal u')
xlabel('Tid (s)')
grid on
title('PID styrsignal')

figure;
plot((1:N)*dt, Vdot_log, 'b-', 'LineWidth', 1.5)
ylabel('Volym (ml)')
grid on
title('Ballastvolym')
figure;
plot((1:N)*dt, drag_log, 'b-', 'LineWidth', 1.5)
ylabel('drag (N)')
grid on
title('drag')
