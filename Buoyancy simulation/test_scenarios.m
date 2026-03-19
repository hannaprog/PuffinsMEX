
%step response and hold depth, r
function z_ref = stepDepth(t)
    if t < 10
        z_ref = 0;
    elseif t < 30
        z_ref = 3;
    else
        z_ref = 5;
    end
end



% Osäkra faktorer: vikt, drag, surface bouyancy

