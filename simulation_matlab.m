clear; clc;

%% PARAMETRAR
m = 3;                  % massa (kg)
g = 9.81;               % gravitation
rho = 1000;             % vatten densitet

F_pos = 2.94;           % positiv buoyancy (N) vid tom syringe
m_a = 0;                % added mass (kan sättas >0 senare)

k_m = 50; % motor specification, rad/s per u
p = 0.002; % lead screw, meter per lap 

d = 0.1; % diameter syringe m
area = pi*(d/2)^2; % syringe, area, m^2

V_max = 0.0005;         % max syringe volym (500 ml)

d1 = 5;                 % linjär drag

%% PID
Kp = 30;
Ki = 0.5;
Kd = 20;

%% SIMULERING
dt = 0.01;
T = 60;
N = T/dt;

z = 0;                  % djup (m), 0 = yta
w = 0;                  % hastighet (m/s)
V = 0;                  % syringe volym

z_ref = 0;              % önskat djup

e_int = 0;
e_prev = 0;

% logg
z_log = zeros(N,1);
w_log = zeros(N,1);
V_log = zeros(N,1);
u_log = zeros(N,1);

% Beräkna feedforward volym
V_ff = (F_pos - m*g)/(rho*g);
V = min(V_ff, V_max);  % fyll max V om V_ff > V_max

%% LOOP
for i = 1:N
    if i > 1000
        z_ref = 3;          
    end
    % --- PID ---
    e = z_ref - z;
    e_int = e_int + e*dt;
    e_der = (e - e_prev)/dt;
    
    u = Kp*e + Ki*e_int + Kd*e_der;
    
    % saturera styrsignal
    u = max(min(u, 200), -200)

    e_prev = e;
    
    % --- Syringe --
    
    V_dot = k_m * u * p * area;
    V = V + V_dot*dt;
    
    % saturera volym
    V = max(min(V, V_max), 0);
    
    % --- Buoyancy ---
    F_b = rho*g*V + m*g - F_pos ;
    
    % --- Drag ---
    D = d1 * w;
    
    % --- Nettokraft ---
    m_eff = rho*V;          % vatten i tanken ökar massa
    F_net = m_eff*g - F_pos - D;
    
    % --- Heave dynamik ---
    w_dot = F_net / (m_eff);
    w = w + w_dot*dt;
    w = max(min(w, 1), -1); % t.ex max 1 m/s
    
    % --- Surface constraint ---
    if z <= 0 && w < 0
        w = 0;
    end
    
    % --- Position ---
    z = z + w*dt;
    
    % --- logga ---
    z_log(i) = z;
    w_log(i) = w;
    V_log(i) = V;
    u_log(i) = u;
end

%% PLOTTAR
figure;

subplot(3,1,1)
plot((1:N)*dt, z_log)
ylabel('Depth z (m)')
grid on

subplot(3,1,2)
plot((1:N)*dt, V_log/10^-6)
ylabel('Volume (ml)')
grid on

subplot(3,1,3)
plot((1:N)*dt, u_log)
ylabel('Control u')
xlabel('Time (s)')
grid on