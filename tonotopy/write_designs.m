function write_designs(pth)
% pth="/Volumes/gdrive4tb/IGNITE/tonotopy/glm/IGNTFA_00065";
    if or(isempty(dir('fsf_template.txt')),true)
        load(fullfile(pth,'logFiles','sequence.mat'),'TR')
        FId = fopen('fsf_template.txt','wt');
        fprintf(FId,'set fmri(version) 6.00\n');
        fprintf(FId,'set fmri(level) 1\n');
        fprintf(FId,'set fmri(tr) %g\n',(TR));
        fprintf(FId,'set fmri(npts) xxx\n');
        fprintf(FId,'set fmri(ndelete) 0\n');
        fprintf(FId,'set fmri(filtering_yn) 0\n');
        fprintf(FId,'set fmri(critical_z) 5.3\n');
        fprintf(FId,'set fmri(brain_thresh) 10\n');
        fprintf(FId,'set fmri(noise) 0.66\n');
        fprintf(FId,'set fmri(noisear) 0.34\n');
        fprintf(FId,'set fmri(temphp_yn) 0\n');
        fprintf(FId,'set fmri(templp_yn) 0\n');
        fprintf(FId,'set fmri(motionevs) 0\n');
        fprintf(FId,'set fmri(mixed_yn) 2\n');
        fprintf(FId,'set fmri(evs_orig) xxx\n');
        fprintf(FId,'set fmri(evs_real) xxx\n');
        fprintf(FId,'set fmri(evs_vox) 0\n');
        fprintf(FId,'set fmri(ncon_orig) xxx\n');
        fprintf(FId,'set fmri(ncon_real) xxx\n');
        fprintf(FId,'set fmri(nftests_orig) xxx\n');
        fprintf(FId,'set fmri(nftests_real) xxx\n');
        fprintf(FId,'set fmri(paradigm_hp) 100\n');
        fclose(FId);
    end

    FId = fopen('fsf_template.txt','rt');        
    fsf = struct;
    I = 1;
    while ~feof(FId)
        line = fgetl(FId);
        fsf(I).line = line;
        I = I+1;
    end

    % Load the sequence.mat file
    load(fullfile(pth,'logFiles','sequence.mat'),'seq')  

    % Determine conditions and design based on the ev structure
    nreg = [8,16];

    for I = 1:numel(nreg)        
        FId = fopen(fullfile(pth,'designs',sprintf('e_%d.fsf',nreg(I))),'wt');
        % ### general;
        fprintf(FId,'### general\n');
        for f = 1:numel(fsf) 
            if ~contains(fsf(f).line, 'xxx')
                fprintf(FId, '%s\n', fsf(f).line);
            else
                if contains(fsf(f).line, 'npts')
                    fprintf(FId, 'set fmri(npts) %d\n', numel(seq));
                elseif contains(fsf(f).line, 'evs_orig')
                    fprintf(FId, 'set fmri(evs_orig) %d\n', nreg(I));
                elseif contains(fsf(f).line, 'evs_real')
                    fprintf(FId, 'set fmri(evs_real) %d\n', 2*nreg(I));
                elseif contains(fsf(f).line, 'ncon_orig')
                    fprintf(FId, 'set fmri(ncon_orig) %d\n', nreg(I));
                elseif contains(fsf(f).line, 'ncon_real')
                    fprintf(FId, 'set fmri(ncon_real) %d\n', nreg(I));

                 elseif contains(fsf(f).line, 'nftests_orig')
                    if nreg(I) == 8 
                        fprintf(FId, 'set fmri(nftests_orig) 1\n');
                    else
                        fprintf(FId, 'set fmri(nftests_orig) 0\n');
                    end
                elseif contains(fsf(f).line, 'nftests_real')
                    if nreg(I) == 8 
                        fprintf(FId, 'set fmri(nftests_real) 1\n');
                    else
                        fprintf(FId, 'set fmri(nftests_real) 0\n');
                    end
                end
            end
        end
        
        % ### evs;
        fprintf(FId, '### evs\n');
        
        if nreg(I) == 8
            bands = ["band1", "band2", "band3", "band4", "band5", "band6", "band7", "band8"];
        else
            bands = ["rest_band1", "rest_band2", "rest_band3", "rest_band4", "rest_band5", "rest_band6", "rest_band7", "rest_band8", ...
                     "vis_band1", "vis_band2", "vis_band3", "vis_band4", "vis_band5", "vis_band6", "vis_band7", "vis_band8"];
        end
        
        for n = 1:length(bands)
            % Using the band name as the title
            fprintf(FId, 'set fmri(evtitle%d) "%s"\n', n, bands(n));  
            
            fprintf(FId, 'set fmri(shape%d) 3\n', n);
            fprintf(FId, 'set fmri(convolve%d) 2\n', n);
            fprintf(FId, 'set fmri(convolve_phase%d) 0\n', n);
            fprintf(FId, 'set fmri(tempfilt_yn%d) 1\n', n);
            fprintf(FId, 'set fmri(deriv_yn%d) 1\n', n);
            
            % Pointing to the correct .txt file for each band
            fprintf(FId, 'set fmri(custom%d) "%s"\n', n, fullfile(pth, 'logFiles', sprintf('%d', nreg(I)), sprintf('%s.txt', bands(n))));
            
            fprintf(FId, 'set fmri(gammasigma%d) 2\n', n);
            fprintf(FId, 'set fmri(gammadelay%d) 5\n', n);
            for m = 0:length(bands)  % Orthogonalization for each band against every other band
                fprintf(FId, 'set fmri(ortho%d.%d) 0\n', n, m);
            end
        end

        
        % ### cons;
        fprintf(FId, '### cons\n');
        [~, idx] = sort([2*(1:nreg(I))-1 2*(1:nreg(I))]);
        for n = 1:nreg(I)
            con_orig = 1:nreg(I) == n;
            con_real = [2*(1:nreg(I))-1 2*(1:nreg(I))] == 2*n-1; 
            con_real = con_real(idx);
            
            for m = 1:numel(con_orig)
                fprintf(FId, 'set fmri(con_orig%d.%d) %d\n', n, m, con_orig(m));
            end                        
            for m = 1:numel(con_real)
                fprintf(FId, 'set fmri(con_real%d.%d) %d\n', n, m, con_real(m));
            end      
        end
        
        if nreg(I) == 8
            for n = 1:nreg(I)
                fprintf(FId,'set fmri(ftest_orig1.%d) 1\n',n);
                fprintf(FId,'set fmri(ftest_real1.%d) 1\n',n);
            end
        end  
                              
        fclose(FId);
    end 
end





