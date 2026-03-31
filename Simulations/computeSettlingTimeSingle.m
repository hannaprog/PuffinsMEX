function settling_time = computeSettlingTimeSingle(time, signal, ref, tolerance)
% Returnerar första tidpunkt då signalen går in i toleransbandet
% och sedan stannar där resten av simuleringen.
%
% time       : tidsvektor
% signal     : utsignal, t.ex. depth
% ref        : referensvärde
% tolerance  : absolut tolerans, t.ex. 0.05 m

    lower_bound = ref - tolerance;
    upper_bound = ref + tolerance;

    settling_time = NaN;

    for k = 1:length(signal)
        remaining_signal = signal(k:end);

        if all(remaining_signal >= lower_bound & remaining_signal <= upper_bound)
            settling_time = time(k);
            return;
        end
    end
end