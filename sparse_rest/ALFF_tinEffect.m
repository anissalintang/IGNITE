%% Calculate ALFF tinnitus effect
% Loop over the hemispheres
clear
clc
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall'), 'tinEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/merge_mean/';

% Define the conditions and hemispheres
tinnitus = {'tin', 'noTin'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for tin = 1:length(tinnitus)
        
        % Construct the filename
        filename = ['allSubj_', hemispheres{hem}, '_ALFFall_merged_mean_', tinnitus{tin}, '_smooth5.mgz'];
        
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

%%
% Create the variable of tin and noTin in both hemispheres
lh_tin = lh(1,:);
rh_tin = rh(1,:);

lh_noTin = lh(2,:);
rh_noTin = rh(2,:);

% Calculate the tinEffect tin and noTin in both hemisphere..
lh_tin_noTin = (lh_tin - lh_noTin)';
rh_tin_noTin = (rh_tin - rh_noTin)';

% .. and save as images in .mgz
lh_tin_noTin_img=img;
rh_tin_noTin_img=img;

lh_tin_noTin_img.vol=lh_tin_noTin;
rh_tin_noTin_img.vol=rh_tin_noTin;


mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/tinEffect'), 'smooth5');
MRIwrite(lh_tin_noTin_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/tinEffect/smooth5/ALFF_lh_tinEffect_tin_noTin_smooth5.mgz');
MRIwrite(rh_tin_noTin_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/tinEffect/smooth5/ALFF_rh_tinEffect_tin_noTin_smooth5.mgz');

