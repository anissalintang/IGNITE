function curv = fthrcurv(curv,SLOPE)

    curv = erf(SLOPE*2/sqrt(pi)*curv/max(abs(curv(:))));    
end