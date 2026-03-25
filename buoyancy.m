% buoyancy.m 
% Skapad av Marko den 24:e februari

% Physical constants
m   = 3.1; % kg
g   = 9.81; % m/s^2
rho = 1000; % kg/m^3
r = 0.0762/2; % 3 inch tube/chassi
A = pi*r^2; % Frontal area (used for drag force)


% Forces
Fb  = 0.120*g;       % N (buoyancy force). 1 ml of water = 1 gram
Cd  = 0.136;       % drag coefficient
