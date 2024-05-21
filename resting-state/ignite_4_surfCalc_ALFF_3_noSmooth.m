%% Calculate ALFF tinnitus Effect: tin vs noTin -- ALFF
% Loop over the hemispheres
clear
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF'), 'tinEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/merge_mean/';

% Define the conditions and hemispheres
conditions = {'tin', 'noTin'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_', hemispheres{hem}, '_ALFF_merged_mean_', conditions{cond},'.mgz'];
        
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

MRIwrite(lh_tinEffect_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/tinEffect/ALFF_lh_tinEffect.mgz');
MRIwrite(rh_tinEffect_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/tinEffect/ALFF_rh_tinEffect.mgz');


%% Calculate ALFF tinnitus EFfect: tin vs noTin -- ALFF sqr
% Loop over the hemispheres
clear
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF'), 'tinEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/merge_mean/';

% Define the conditions and hemispheres
conditions = {'tin', 'noTin'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_', hemispheres{hem}, '_ALFF_sqr_merged_mean_', conditions{cond},'.mgz'];
        
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

MRIwrite(lh_tinEffect_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/tinEffect/ALFF_sqr_lh_tinEffect.mgz');
MRIwrite(rh_tinEffect_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/tinEffect/ALFF_sqr_rh_tinEffect.mgz');

