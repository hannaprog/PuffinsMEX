clear all
mass = 3; %kg
gravity = 9.81; % m/s^2
weight = mass * gravity; % Weight in Newtons
surface_buoyancy = 2.94;


km = 50; % motor specification, rad/s per u
p = 0.002; % lead screw, meter per lap 

d = 0.1; % diameter syringe mm
area = pi*(d/2)^2; % syringe, area, mm^2
density = 1000;
D = 5;
W = 0;