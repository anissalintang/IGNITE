function jctr = fjordan(grph)
        
    d = distances(grph);
    dmax = max(d,[],2);    
    MIN = min(dmax);
    jctr = find(dmax==MIN);
end