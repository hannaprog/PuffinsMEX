clear all
mass = 3; %kg
gravity = 9.81; % m/s^2
weight = mass * gravity; % Weight in Newtons
surface_buoyancy = 300;


km = 0.02; % motor specification, rad/s per u
p = 0.002; % lead screw, meter per lap 

d = 10; % diameter syringe mm
area = pi*(d/2)^2; % syringe, area, mm^2
density = 1/1000;
D = 0;
W = 0;