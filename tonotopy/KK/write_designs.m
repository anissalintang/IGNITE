function write_designs(pth,SUBJ)
%     pth = fullfile(filesep,'Volumes','gdrive','mri','ProcData','SimHL,'standard/nordic','glm'); 
%     SUBJ = '02344';

    pth = "/Volumes/gdrive4tb/IGNITE/code/tonotopy/KK"; 
    SUBJ = 'test';
    
    if or(isempty(dir('fsf_template.txt')),true)
%         load(fullfile(pth,SUBJ,'logFiles','sequence.mat'),'TA','StimDur')
        FId = fopen('fsf_template.txt','wt');
        fprintf(FId,'set fmri(version) 6.00\n');
        fprintf(FId,'set fmri(level) 1\n');
        fprintf(FId,'set fmri(tr) %g\n',(TA+StimDur)/1000);
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

    eval(sprintf('!mkdir -p %s',fullfile(pth,SUBJ,'designs')))  

%     load(fullfile(pth,SUBJ,'logFiles','sequence.mat'),'seq','nfrq','nerb')
    cond = fieldnames(seq)';
    design = {};
    for I = 1:numel(cond) 
        design = [design cellfun(@(x) sprintf('%s_%s',cond{I},x),fieldnames(seq.(cond{I}))','UniformOutput',false)];
        design = [design {sprintf('%s_cmb',cond{I})} {sprintf('%s_smth',cond{I})}];
    end
    design = [design {'all_smth'}];
    
    nreg = cell(1,numel(design));
    for I = 1:numel(design)
        if contains(design{I},'cmb')
            nreg{I} = nfrq;
        else
            nreg{I} = nfrq(1);
        end
    end        

    for I = 1:numel(design)        
        for II = 1:numel(nreg{I})
            FId = fopen(fullfile(pth,SUBJ,'designs',sprintf('%s_%d.fsf',design{I},nreg{I}(II))),'wt');
            
            % ### general;
            fprintf(FId,'### general\n');
            for III = 1:numel(fsf) 
                if ~contains(fsf(III).line,'xxx')
                    fprintf(FId,'%s\n',fsf(III).line);
                elseif contains(fsf(III).line,'npts')
                    tmp = split(design{I},'_');
                    if strcmp(tmp{1},'all')
                        fprintf(FId,'set fmri(npts) %d\n',sum(cell2mat(cellfun(@(x) cellfun(@(y) numel(seq.(x).(y)),fieldnames(seq.(x))'),cond,'UniformOutput',false))));                        
                    elseif or(strcmp(tmp{2},'cmb'),strcmp(tmp{2},'smth'))
                        fprintf(FId,'set fmri(npts) %d\n',sum(cellfun(@(x) numel(seq.(tmp{1}).(x)),fieldnames(seq.(tmp{1})))));   
                    else
                        fprintf(FId,'set fmri(npts) %d\n',numel(seq.(tmp{1}).(tmp{2}))); 
                    end
                elseif contains(fsf(III).line,'evs_orig')
                    fprintf(FId,'set fmri(evs_orig) %d\n',nreg{I}(II));
                elseif contains(fsf(III).line,'evs_real')
                    fprintf(FId,'set fmri(evs_real) %d\n',2*nreg{I}(II));
                elseif contains(fsf(III).line,'ncon_orig')
                    fprintf(FId,'set fmri(ncon_orig) %d\n',nreg{I}(II));
                elseif contains(fsf(III).line,'ncon_real')
                    fprintf(FId,'set fmri(ncon_real) %d\n',nreg{I}(II));
                elseif contains(fsf(III).line,'nftests_orig')
                    if contains(design{I},'smth')
                        fprintf(FId,'set fmri(nftests_orig) 1\n');
                    else
                        fprintf(FId,'set fmri(nftests_orig) 0\n');
                    end
                elseif contains(fsf(III).line,'nftests_real')
                    if contains(design{I},'smth')
                        fprintf(FId,'set fmri(nftests_real) 1\n');
                    else
                        fprintf(FId,'set fmri(nftests_real) 0\n');
                    end                            
                end
            end
            
            % ### evs;
            fprintf(FId,'### evs\n');
            for III = 1:nreg{I}(II)
                fprintf(FId,'set fmri(evtitle%d) "%g kHz"\n',III,nerb{II}(III));
%                 fprintf(FId,'set fmri(evtitle%d) "%g kHz"\n',III,nerb2f(nerb{II}(III)));
                fprintf(FId,'set fmri(shape%d) 3\n',III);
                fprintf(FId,'set fmri(convolve%d) 2\n',III);
                fprintf(FId,'set fmri(convolve_phase%d) 0\n',III);
                fprintf(FId,'set fmri(tempfilt_yn%d) 1\n',III);
                fprintf(FId,'set fmri(deriv_yn%d) 1\n',III);
                if ~contains(design{I},'smth')
                    fprintf(FId,'set fmri(custom%d) "%s"\n',III,fullfile(pth,SUBJ,'logFiles',...
                        sprintf('%s_%d',design{I},nreg{I}(II)),sprintf('ev%d.txt',III)));
                else
                    tmp = split(design{I},'_'); fprintf(FId,'set fmri(custom%d) "%s"\n',III,fullfile(pth,SUBJ,'logFiles',...
                        sprintf('%s_cmb_%d',tmp{1},nreg{I}(II)),sprintf('ev%d.txt',III)));
                end
                fprintf(FId,'set fmri(gammasigma%d) 2\n',III);
                fprintf(FId,'set fmri(gammadelay%d) 5\n',III);
                for IV = 0:nreg{I}(II)
                    fprintf(FId,'set fmri(ortho%d.%d) 0\n',III,IV);
                end
            end
            
            % ### cons;
            fprintf(FId,'### cons\n');
            [~,idx] = sort([2*(1:nreg{I}(II))-1 2*(1:nreg{I}(II))]);
            for III = 1:nreg{I}(II)
                con_orig = 1:nreg{I}(II)==III;
                con_real = [2*(1:nreg{I}(II))-1 2*(1:nreg{I}(II))]==2*III-1; con_real = con_real(idx);
                
                for IV = 1:numel(con_orig)
                    fprintf(FId,'set fmri(con_orig%d.%d) %d\n',III,IV,con_orig(IV));
                end                        
                for IV = 1:numel(con_real)
                    fprintf(FId,'set fmri(con_real%d.%d) %d\n',III,IV,con_real(IV));
                end      
            end
            if contains(design{I},'smth')                
                for III = 1:nreg{I}(II)
                    fprintf(FId,'set fmri(ftest_orig1.%d) 1\n',III);
                    fprintf(FId,'set fmri(ftest_real1.%d) 1\n',III);
                end                        
            end           
            fclose(FId); 
        end
    end
end




