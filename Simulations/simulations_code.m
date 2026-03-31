clear; clc;

%% ================= PARAMETRAR =================

% Farkost
m = 3;                  
g = 9.81;
rho = 1000;

% Added mass + hydrodynamik
m_a = 2.5;
C_d = 1.0;
A_cross = 0.07;
d1 = 5;                 % linjär dämpning (VIKTIG)

results = struct();

% Buoyancy
F_pos = 2.94 + m*g;     
V_max = 0.0005;         

% Stepper + ledskruv + syringe
k_m = 5;                 % rad/s per styrsignal
p = 0.002;               % ledskruv stigning
d = 0.1;                 
A = pi*(d/2)^2;          % kolvareal
x_max = V_max / A;       % max slaglängd

motor_torque = 0.65;
F_motor_max = 2*pi*motor_torque/p;

% Hydraulik (NY MODELL)
P_atm = 101325;
K_h = 2e8;               % hydraulisk styvhet (bulk modulus)
R_flow = 5e8;            % slangmotstånd (tunas!)

% PID (bra startvärden)
Kp = 0.3;
Kd = 6;
Ki = 0;

%% ================= SIMULERING =================

dt = 0.1;
T = 120;
N = T/dt;

% Tillstånd
z = 0;        % djup
w = 0;        % hastighet
V = 0;        % faktisk vattenvolym i spruta
x = 0;        % kolvposition (NY!)

% PID tillstånd
e_int = 0;
e_prev = 0;

% Loggning
z_log=zeros(N,1); w_log=zeros(N,1);
V_log=zeros(N,1); x_log=zeros(N,1);
u_log=zeros(N,1);

%% ================= HUVUDLOOP =================
for i = 1:N
    z_ref = 3;   % måldjup

    % ---- Feedforward ----
    V_neutral = F_pos / (rho*g);     % volym för neutral buoyancy
    V_extra = 0.0002;                % extra för snabb start
    V_ff = V_neutral + V_extra;
    V_ff = min(V_ff, V_max);         % begränsa max volym
    x_ff = V_ff / A;                 % kolvreferens från feedforward
    
    %% ----- PID djup -----
    e = z_ref - z;
    e_int = e_int + e*dt;
    e_der = (e - e_prev)/dt;
    u = Kp*e + Ki*e_int + Kd*e_der;
    e_prev = e;

    % ---- Motorstyrsignal ----
    k_colv = 5;                     % hur snabbt kolven vill nå x_ff
    u_ff = k_colv * (x_ff - x) *z_ref;     % feedforward-del
    u = u + u_ff;
    u = max(min(u,1),-1);           % styrsignal -1..1

    %% ----- KOLV DYNAMIK -----
    % last från hydrostatiskt tryck
    P_hydro = rho*g*z + P_atm;
    F_load = P_hydro * A;

    % motor blir långsammare när lasten ökar
    speed_factor = 1; %max(0, 1 - F_load/F_motor_max);

    % kolvhastighet
    x_dot = k_m * u * p;
    x = x + x_dot*dt;
    x = max(min(x,x_max),0);

    % volym som kolven "vill" skapa
    V_piston = A*x;

    %% ----- HYDRAULIK -----
    % tryck i sprutan (hydraulisk fjäder)
    P_syr = P_atm + K_h*(V_piston - V);

    % flöde genom slang
    Q = (P_syr - P_hydro)/R_flow;
    V = V + Q*dt;
    V = max(min(V,V_max),0);

    %% ----- BUOYANCY -----
    F_b = rho*g*V + m*g - F_pos;

    %% ----- DRAG (linjär + kvadratisk) -----
    D = d1*w + 0.5*rho*C_d*A_cross*abs(w)*w;

    %% ----- RÖRELSEEKVATION -----
    F_net = F_b - D;
    m_eff = m + m_a;

    w_dot = F_net/m_eff;
    w = w + w_dot*dt;
    z = z + w*dt;
    z = max(z,0);

    % --- Ythantering ---
    if z <= 0 && w < 0
        w = 0;
        z = 0;
        %V = V_innan;
    end
    %% ----- LOGGA -----
    z_log(i)=z;
    w_log(i)=w;
    V_log(i)=V*1e6;
    x_log(i)=x*1000;
    u_log(i)=u;
end

%% ================= PLOT =================
t=(1:N)*dt;

figure;
subplot(3,1,1)
plot(t,z_log,'LineWidth',1.5); hold on
plot(t,3*ones(N,1),'--')
ylabel('Djup (m)')
title('Djupreglering med ballastkolv')
grid on

subplot(3,1,2)
plot(t,V_log,'LineWidth',1.5)
ylabel('Volym (ml)')
grid on

subplot(3,1,3)
plot(t,u_log,'LineWidth',1.5)
ylabel('Styrsignal')
xlabel('Tid (s)')
grid on

figure;
plot(t,x_log,'LineWidth',1.5)
ylabel('Kolvposition (mm)')
xlabel('Tid (s)')
title('Kolvslag')
grid on
figure;

plot(t,w_log,'LineWidth',1.5)
ylabel('Kolvposition (mm)')
xlabel('Tid (s)')
title('Kolvslag')
grid on

results(1).time = t;
results(1).depth_mean = z_log;


results = computeSettlingTime(results, z_ref, 0.1)