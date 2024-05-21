function nerb = f2nerb(f)
    % nerb = integral of 1/erb(f) from 0 to f!
    
    nerb = 1000*log(10)/(24.67*4.37)*log10(4.37*f+1);
end