function read_logfiles(pth,opt,SUBJ)    
    pth = "/Volumes/gdrive4tb/IGNITE/code/tonotopy/KK";
    opt = 'nordic';
    SUBJ = 'test';

    mkdir(fullfile(pth,'glm','logFiles'))
    
    cond = {'nh' 'hl'};
    nruns = zeros(size(cond));
    for I = 1:numel(cond)
        nruns(I) = numel(dir(fullfile(pth,'fmri_r1.txt')));
    end

    seq = struct;
    ev = struct;
    for I = 1:numel(cond)
        file = dir(fullfile(pth,'*.txt'));        
        for II = 1:nruns(I)
            FILE = file(arrayfun(@(x) contains(x.name,sprintf('r%d',II)),file)); 
            
            FId = fopen(fullfile(FILE.folder,FILE.name),'rt');
            line = fgetl(FId);
            while ~contains(line,'---')                
                if contains(line,'=')
                    tmp = split(line,'=');            
                    switch(strtrim(tmp{1}))
                    case('lowFrequency')
                        lowFrq = sscanf(tmp{2},'%g');
                    case('highFrequency')
                        highFrq = sscanf(tmp{2},'%g');
                    case('nFrequencies')
                        NFrq = sscanf(tmp{2},'%d');
                    case('nSilence')
                        NSil = sscanf(tmp{2},'%d');
                    case('nRepeats')
                        NRep = sscanf(tmp{2},'%d'); 
                    case('acqDur')
                        TA = sscanf(tmp{2},'%g');      
                    case('stimWindow')
                        StimDur = sscanf(tmp{2},'%g');
                    end
                end
                line = fgetl(FId);
            end                    

            seq.(cond{I}).(sprintf('r%d',II)) = [];  
            scan = zeros(1,2);
            while ~feof(FId)
                line = fgetl(FId);
                tmp = split(line);
                if ~isempty(sscanf(tmp{1},'%d'))
                    scan(end) = sscanf(tmp{1},'%d');
                    if diff(scan)>0
                        seq.(cond{I}).(sprintf('r%d',II)) = [seq.(cond{I}).(sprintf('r%d',II));sscanf(tmp{2},'%d')];
                        scan = circshift(scan,-1);
                    end
                end
            end
            fclose(FId);

            nerb = cell(1,2);
%             nerb{2} = f2nerb(lowFrq):(f2nerb(highFrq)-f2nerb(lowFrq))/(NFrq-1):f2nerb(highFrq); 
            nerb{2}=[3.3630,4.3264,5.2899,6.2533,7.2167,8.1802,9.1436,10.1071,11.0705,12.0339,12.9974,13.9608,14.9242,15.8877,16.8511,17.8146,18.7780,19.7414,20.7049,21.6683,22.6317,23.5952,24.5586,25.5220,26.4855,27.4489,28.4124,29.3758,30.3392,31.3027,32.2661,33.2295]
%             nerb{1} = arrayfun(@(x) mean(nerb{2}((x-1)*4+1:(x-1)*4+4)),1:NFrq/4);
            nerb{1}=[4.8082,8.6619,2.5156,16.3694,20.2231,24.0769,27.9306,31.7844];
            nfrq = cellfun(@(x) numel(x),nerb);       
    
            if numel(seq.(cond{I}).(sprintf('r%d',II)))<nfrq(2)*NRep+NSil+1 
                % in 02344_034, the scanner trigger was not working for the first two volumes of the first functional scan due to an 
                % operator error;
                seq.(cond{I}).(sprintf('r%d',II)) = [(nfrq(2)+1)*ones(nfrq(2)*NRep+NSil+1-numel(seq.(cond{I}).(sprintf('r%d',II))),1);[seq.(cond{I}).(sprintf('r%d',II))(1:end-1);0]];
            end
                
            ev.(cond{I}).(sprintf('r%d',II)).(sprintf('N%d',nfrq(2))) = cell(1,nfrq(2));
            for III = 1:nfrq(2)
                tmp = (find(seq.(cond{I}).(sprintf('r%d',II))==III)-1)*(TA+StimDur)+TA+StimDur/2;
                % As explained on the feat FAQs page (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT/FAQ), feat assumes
                % that the volumes were acquired at TR/2, and so, stimulus onset times have to be increased by (TR-TA)/2 = StimDur/2;  
                 ev.(cond{I}).(sprintf('r%d',II)).(sprintf('N%d',nfrq(2))){III} = [(tmp/1000) repmat(StimDur/1000,numel(tmp),1) ones(numel(tmp),1)];
            end
        
            ev.(cond{I}).(sprintf('r%d',II)).(sprintf('N%d',nfrq(1))) = cell(1,nfrq(1));
            for III = 1:(nfrq(1))
                tmp = (find(ceil(seq.(cond{I}).(sprintf('r%d',II))/4)==III)-1)*(TA+StimDur)+TA+StimDur/2;
                ev.(cond{I}).(sprintf('r%d',II)).(sprintf('N%d',nfrq(1))){III} = [(tmp/1000) repmat(StimDur/1000,numel(tmp),1) ones(numel(tmp),1)];
            end
        end
    end
        
    % Save seq and event structures;      
    save(fullfile(pth,'glm','logFiles','sequence.mat'),'TA','StimDur','NRep','NSil','nfrq','nerb','seq','ev')
       
    % 1. Save events for individual runs;
    for I = 1:numel(cond)    
        for II = 1:nruns(I)  
            mkdir(fullfile(pth,opt,'glm',SUBJ,'logFiles',sprintf('%s_r%d_%d',cond{I},II,nfrq(1))))
            for III = 1:nfrq(1)
                FId = fopen(fullfile(pth,opt,'glm',SUBJ,'logFiles',sprintf('%s_r%d_%d',cond{I},II,nfrq(1)),sprintf('ev%d.txt',III)),'wt');
                for IV = 1:size(ev.(cond{I}).(sprintf('r%d',II)).(sprintf('N%d',nfrq(1))){III},1)
                    fprintf(FId,'%g\t%g\t%g\n',ev.(cond{I}).(sprintf('r%d',II)).(sprintf('N%d',nfrq(1))){III}(IV,:));
                end
                fclose(FId);
            end
        end
    end

    % 2. Save events for combined runs; 
    for I = 1:numel(cond)    
        run = arrayfun(@(x) sprintf('r%d',x),1:nruns(I),'UniformOutput',false);
        nvol = cellfun(@(x) numel(seq.(cond{I}).(x)),run); 
        offst = cumsum(nvol)*(TA+StimDur)/1000; offst = [0 offst(1:end-1)]; 
        for II = 1:numel(nfrq)
            mkdir(fullfile(pth,opt,'glm',SUBJ,'logFiles',sprintf('%s_cmb_%d',cond{I},nfrq(II))))
            for III = 1:nfrq(II)
                FId = fopen(fullfile(pth,opt,'glm',SUBJ,'logFiles',sprintf('%s_cmb_%d',cond{I},nfrq(II)),sprintf('ev%d.txt',III)),'wt');
                for IV = 1:nruns(I)
                    for V = 1:size(ev.(cond{I}).(sprintf('r%d',IV)).(sprintf('N%d',nfrq(II))){III},1)
                        fprintf(FId,'%g\t%g\t%g\n',ev.(cond{I}).(sprintf('r%d',IV)).(sprintf('N%d',nfrq(II))){III}(V,1)+offst(IV),...
                            ev.(cond{I}).(sprintf('r%d',IV)).(sprintf('N%d',nfrq(II))){III}(V,2),ev.(cond{I}).(sprintf('r%d',IV)).(sprintf('N%d',nfrq(II))){III}(V,3));
                    end
                end
                fclose(FId);
            end
        end
    end    
                
    mkdir(fullfile(pth,'glm','logFiles',sprintf('all_cmb_%d',nfrq(1))))
    for I = 1:nfrq(1)
        FId = fopen(fullfile(pth,opt,'glm',SUBJ,'logFiles',sprintf('all_cmb_%d',nfrq(1)),sprintf('ev%d.txt',I)),'wt');
        OFFST = 0;
        for II = 1:numel(cond)
            for III = 1:nruns(II)
                for IV = 1:size(ev.(cond{II}).(sprintf('r%d',III)).(sprintf('N%d',nfrq(1))){I},1)
                    fprintf(FId,'%g\t%g\t%g\n',ev.(cond{II}).(sprintf('r%d',III)).(sprintf('N%d',nfrq(1))){I}(IV,1)+OFFST,...
                        ev.(cond{II}).(sprintf('r%d',III)).(sprintf('N%d',nfrq(1))){I}(IV,2),ev.(cond{II}).(sprintf('r%d',III)).(sprintf('N%d',nfrq(1))){I}(IV,3));
                end
                OFFST = OFFST+numel(seq.(cond{II}).(sprintf('r%d',III)))*(TA+StimDur)/1000;
            end
        end
        fclose(FId);
    end
end
                
        
        
            
            
            
            
            
