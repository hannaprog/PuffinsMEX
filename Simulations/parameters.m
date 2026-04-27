% Farkost
m = 4.567+0.2; 
g = 9.81;
rho = 1000;
m_a = 0;

d1 = 5;
C_d = 0.136;

A_cross = 0.090; %utsida chassi

% Buoyancy
F_pos = 0.300 * g + m*g; %buoyancy force  

V_max = 0.0005; % max volume intake       

% Stepper + ledskruv + syringe
p = 0.002;               % ledskruv pitch
d = 0.064;               % insida syringe
A = pi*(d/2)^2;          % kolvareal
x_max = V_max / A;       % max slaglängd

%motor_torque = 0.65;
%F_motor_max = 2*pi*motor_torque/p;

p_atm = 101325;
V_air = 1000e-6;   
rpm_max = 440;                             
F_stall = 700;

% Hose flow limit
v_hose_max = 2.0;                    % m/s, measured max fluid velocity in hose
d_hose = 0.005;                        % inner diameter of hose [m]
A_hose = pi*(d_hose/2)^2;            % hose cross-sectional area [m^2]
Q_max = v_hose_max * A_hose;         % max volume flow through hose [m^3/s]
piston_vel_max = Q_max/A;

V_supply = 11.1;
I_move   = 1.5; 
I_hold   = 0.5;  

% %% PARAMETRAR - GRUNDMODELL
% % Farkost
% m = 3;                      % massa (kg)
% g = 9.81;                   % gravitation (m/s^2)
% rho = 1000;                 % vattendensitet (kg/m^3)
% 
% % Buoyancy
% F_pos = 2.94 + m*g;               % positiv flytkraft vid tom tank (N)
% V_max = 0.0005;             % max volym (m^3) = 500 ml
% V_dot_max = 0.001;
% 
% % Aktuator (stepper + lead screw + syringe)
% k_m = 50;                   % motor konstant (rad/s per styr信号)
% p = 0.002;                  % ledskruv stigning (m/varv)
% d = 0.1;                    % syringe diameter (m)
% A = pi*(d/2)^2;             % syringe area (m^2)
% A_utlopp = pi*(0.01/2)^2;
% 
% % Dynamik
% d1 = 5;                     % linjär dragkoefficient (N/(m/s))
% m_a = 2.5;  % added mass
% C_d = 1.0;
% A_cross = 0.07;
% motor_torque = 0.65;
% P_atm = 101325;             % Atmosfärstryck (Pa)​
% F_motor_max = 2*pi*motor_torque/p;           % Max kraft från motor/ledskruv (N)
% R_flow = 1e5;               % Flödesmotstånd (Pa·s/m³)