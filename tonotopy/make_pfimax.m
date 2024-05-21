function make_pfimax(infile,outfile)

    mri = MRIread(infile);
    
    PFI = unique(mri.vol);
    pfiprob = cell2mat(arrayfun(@(x) sum(mri.vol==x,4),PFI,'UniformOutput',false));
    [~,pfimax] = max(pfiprob);
    
    mri.vol = pfimax;
    mri.nframes = 1;
    MRIwrite(mri,outfile);
end
