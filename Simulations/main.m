%% Simulation för att jämföra kontrollers
% Kör två controllers med disturbances.

%% Parameterinställningar
clear; clc; close all;
run('parameters.m');

actuation_methods = {'thruster','buoyancy'};
controllers = {'PID','IPD'};           % Controller typer
disturbances = [0, 0.1, 0.2, 0.3];       % Amplituder av disturbance (m/s^2)
simTime = 20;                           % Simuleringstid [s]
nRepetitions = 5;

results = struct();
scenarioID = 1;

%% Loop över actuation, controller, disturbance och repetition
for a = 1:length(actuation_methods)
    act_method = actuation_methods{a};
    
    for c = 1:length(controllers)
        controller_type = controllers{c};
        
        for d = 1:length(disturbances)
            disturbance_amp = disturbances(d);
            
            for r = 1:nRepetitions
                
                %% Skapa simulation input
                simIn = Simulink.SimulationInput([act_method '_simulation']);
                simIn = simIn.setVariable('controller_type', controller_type);
                simIn = simIn.setVariable('disturbance_amp', disturbance_amp);
                
                %% Kör simulering
                simOut = sim(simIn, 'StopTime', num2str(simTime));
                
                %% Spara resultat
                results(scenarioID).actuation = act_method;
                results(scenarioID).controller = controller_type;
                results(scenarioID).disturbance = disturbance_amp;
                results(scenarioID).repetition = r;
                results(scenarioID).time = simOut.tout;
                results(scenarioID).depth = simOut.depth;
                
                %% Beräkna RMS-error och max deviation direkt
                reference = zeros(size(simOut.depth));
                results(scenarioID).RMS_error = sqrt(mean((simOut.depth - reference).^2));
                results(scenarioID).max_deviation = max(abs(simOut.depth - reference));
                
                scenarioID = scenarioID + 1;
            end
        end
    end
end

%% Spara alla resultat
save('AllSimResults.mat','results');