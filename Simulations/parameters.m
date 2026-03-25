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
k_m = 50;                   % motor konstant (rad/s per styr信号)
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