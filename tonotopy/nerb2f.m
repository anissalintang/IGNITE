function f = nerb2f(nerb)
    % nerb2f = inv(f2nerb)!
    
    f = (10.^(nerb*24.67*4.37/(1000*log(10)))-1)/4.37;
end