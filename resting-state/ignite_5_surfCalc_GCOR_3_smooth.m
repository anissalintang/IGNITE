%% Calculate GCOR tinnitus EFfect: tin vs noTin

%% wholeBrain hemisphere
clear
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR'), 'tinEffect')
% Define the parent folder where all of the subject folders are located
parent_folder = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/merge_mean/';

% Define the conditions and hemispheres
conditions = {'tin', 'noTin'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

% SAME hemisphere
% Loop over the hemispheres
for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_', hemispheres{hem}, '_GCOR_wholeBrain_merged_mean_', conditions{cond},'_smooth5.mgz'];
        
        % Load the image and get the values
        img = MRIread([parent_folder, filename]);
        values = img.vol(:);
        
        % Append the values to the appropriate matrix
        if strcmp(hemispheres{hem}, 'lh')
            lh = [lh; values'];
        elseif strcmp(hemispheres{hem}, 'rh')
            rh = [rh; values'];
        end
        
    end
    
end

% Create the variable of tin and noTin in both hemispheres
lh_tin = lh(1,:);
rh_tin = rh(1,:);

lh_noTin = lh(2,:);
rh_noTin = rh(2,:);

% Calculate the stimEffect in both hemisphere..
lh_tinEffect = (lh_tin - lh_noTin)';
rh_tinEffect = (rh_tin - rh_noTin)';

% .. and save as images in .mgz
lh_tinEffect_img=img;
rh_tinEffect_img=img;

lh_tinEffect_img.vol=lh_tinEffect;
rh_tinEffect_img.vol=rh_tinEffect;

mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect'), 'smooth5')
MRIwrite(lh_tinEffect_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_wholeBrain_lh_tinEffect_smooth5.mgz');
MRIwrite(rh_tinEffect_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_wholeBrain_rh_tinEffect_smooth5.mgz');


