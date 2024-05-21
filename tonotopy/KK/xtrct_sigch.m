function xtrct_sigch(pth)
%     pth = fullfile(filesep,'Volumes','gdrive','mri','ProcData','SimHL','nordic');

    subj = dir(fullfile(pth,'surf','*'));
    subj = subj(arrayfun(@(x) ~contains(subj(x).name,'.'),1:numel(subj)));
    subj = unique(arrayfun(@(x) subj(x).name,1:numel(subj),'UniformOutput',false));

    hemi = dir(fullfile(pth,'surf',subj{1},'all_smth_8'));
    hemi = hemi(arrayfun(@(x) ~hemi(x).isdir,1:numel(hemi)));
    hemi = arrayfun(@(x) hemi(x).name,1:numel(hemi),'UniformOutput',false); 
    for I = 1:numel(hemi), tmp = split(hemi{I},'.'); hemi{I} = tmp{1}; end

    design = dir(fullfile(pth,'surf','*','*'));
    design = design(arrayfun(@(x) and(~contains(design(x).name,'.'),~contains(design(x).name,'smth')),1:numel(design)));
    design = unique(arrayfun(@(x) design(x).name,1:numel(design),'UniformOutput',false));

    load(fullfile(pth,'patch','patch.mat'),'ptch')    
    ptch2surf = ptch.map2surf;    

    schavg = struct; schlay = struct;
    for I = 1:numel(design)
        tmp = split(design{I},'_'); COND = tmp{1}; RUN = tmp{2}; NFRQ = sprintf('n%s',tmp{3}); 
        schavg.(COND).(RUN).(NFRQ) = cell(numel(subj),numel(hemi));
        schlay.(COND).(RUN).(NFRQ) = cell(numel(subj),numel(hemi));
        for II = 1:numel(subj)
            for III = 1:numel(hemi)
                mri = MRIread(fullfile(pth,'surf',subj{II},design{I},sprintf('%s.sigch.avg.lh.fssym.mgz',hemi{III})));
                schavg.(COND).(RUN).(NFRQ){II,III} = squeeze(mri.vol(:,ptch2surf,:,:));
                mri = MRIread(fullfile(pth,'surf',subj{II},design{I},sprintf('%s.sigch.lay.lh.fssym.mgz',hemi{III})));
                schlay.(COND).(RUN).(NFRQ){II,III} = squeeze(mri.vol(2:end,ptch2surf,:,:));
            end
        end
    end
    save(fullfile(pth,'patch','schavg.mat'),'subj','hemi','schavg')    
    save(fullfile(pth,'patch','schlay.mat'),'subj','hemi','schlay')
end
