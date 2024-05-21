function xtrct_sigch(pth)
%     pth = fullfile(filesep,'Volumes','gdrive','mri','ProcData','SimHL','nordic');
    % pth = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface';

    subj = dir(fullfile(pth,'projected','*'));
    subj = subj(arrayfun(@(x) ~contains(subj(x).name,'.'),1:numel(subj)));
    subj = unique(arrayfun(@(x) subj(x).name,1:numel(subj),'UniformOutput',false));

    hemi = dir(fullfile(pth,'projected',subj{1},'e_8.fsf'));
    hemi = hemi(arrayfun(@(x) ~hemi(x).isdir,1:numel(hemi)) & ...
                arrayfun(@(x) ~strcmp(hemi(x).name, '.DS_Store'), 1:numel(hemi)));
    hemi = arrayfun(@(x) hemi(x).name,1:numel(hemi),'UniformOutput',false); 

    for I = 1:numel(hemi), tmp = split(hemi{I},'.'); hemi{I} = tmp{1}; end
    hemi = unique(hemi);

    design = dir(fullfile(pth,'projected','*','*'));
    design = design(arrayfun(@(x) ...
        and(~startsWith(design(x).name,'.'), ...
        and(~contains(design(x).name,'smoothed5.fsf'), ...
        ~contains(design(x).name,'pfimax'))), ...
        1:numel(design)));
    design = unique(arrayfun(@(x) design(x).name, 1:numel(design), 'UniformOutput', false));


    load(fullfile(pth,'patch','patch_fssym.mat'),'ptch','roi')

    ptch2surf = ptch.map2surf;    

    % Map roi to ptch
    ptch_indices = roi.map2ptch;
    
    % Now map the ptch indices to surf
    roi2surf = ptch2surf(ptch_indices);
    
    schavg = struct;
    for I = 1:numel(design)
        tmp = split(design{I},'.'); NFRQ = sprintf('%s',tmp{1}); 
        schavg.(NFRQ) = cell(numel(subj),numel(hemi));
        for II = 1:numel(subj)
            for III = 1:numel(hemi)
                mri = MRIread(fullfile(pth,'projected',subj{II},design{I},sprintf('%s.sigch.avg.lh.fssym.mgz',hemi{III})));
                schavg.(NFRQ){II,III} = squeeze(mri.vol(:,roi2surf,:,:));
            end
        end
    end
    save(fullfile(pth,'patch','schavg.mat'),'subj','hemi','schavg')    
end
