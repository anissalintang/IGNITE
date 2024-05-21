%% Calculate ALFF stim Effect -TIN
% Loop over the hemispheres
clear
clc
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/merge_mean/';

% Define the conditions and hemispheres
conditions = {'rest', 'vis'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_', hemispheres{hem}, '_ALFF_merged_mean_tin_', conditions{cond}, '.mgz'];
        
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
% Create the variable of NS and VS in both hemispheres
lh_NS = lh(1,:);
rh_NS = rh(1,:);

lh_VS = lh(2,:);
rh_VS = rh(2,:);

% Calculate the stimEffect NS and VS in both hemisphere..
lh_NS_VS = (lh_VS - lh_NS)';
rh_NS_VS = (rh_VS - rh_NS)';

% .. and save as images in .mgz
lh_NS_VS_img=img;
rh_NS_VS_img=img;

lh_NS_VS_img.vol=lh_NS_VS;
rh_NS_VS_img.vol=rh_NS_VS;


% mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect'), 'noSmooth');
% MRIwrite(lh_NS_VS_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_lh_stimEffect_NS_VS_TIN_noSmooth.mgz');
% MRIwrite(rh_NS_VS_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_rh_stimEffect_NS_VS_TIN_noSmooth.mgz');

%% Calculate the stimEffect NS and VS in both hemisphere against NS
lh_NS_VS_ave = (((lh_VS - lh_NS)./(lh_NS)))';
rh_NS_VS_ave = (((rh_VS - rh_NS)./(rh_NS)))';

% .. and save as images in .mgz
lh_NS_VS_ave_img=img;
rh_NS_VS_ave_img=img;

lh_NS_VS_ave_img.vol=lh_NS_VS_ave;
rh_NS_VS_ave_img.vol=rh_NS_VS_ave;

MRIwrite(lh_NS_VS_ave_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_lh_stimEffect_NS_VS_ave_TIN_noSmooth.mgz');
MRIwrite(rh_NS_VS_ave_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_rh_stimEffect_NS_VS_ave_TIN_noSmooth.mgz');

























%% Calculate ALFF stim Effect -NO TIN
% Loop over the hemispheres
clear
clc
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/merge_mean/';

% Define the conditions and hemispheres
conditions = {'rest', 'vis'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_', hemispheres{hem}, '_ALFF_merged_mean_noTin_', conditions{cond}, '.mgz'];
        
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
% Create the variable of NS and VS AS in both hemispheres
lh_NS = lh(1,:);
rh_NS = rh(1,:);

lh_VS = lh(2,:);
rh_VS = rh(2,:);

% Calculate the stimEffect NS and VS in both hemisphere..
lh_NS_VS = (lh_VS - lh_NS)';
rh_NS_VS = (rh_VS - rh_NS)';

% .. and save as images in .mgz
lh_NS_VS_img=img;
rh_NS_VS_img=img;

lh_NS_VS_img.vol=lh_NS_VS;
rh_NS_VS_img.vol=rh_NS_VS;


% mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect'), 'noSmooth');
% MRIwrite(lh_NS_VS_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_lh_stimEffect_NS_VS_noTIN_noSmooth.mgz');
% MRIwrite(rh_NS_VS_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_rh_stimEffect_NS_VS_noTIN_noSmooth.mgz');

%% Calculate the stimEffect NS and VS in both hemisphere against the average of
% task-res
lh_NS_VS_ave = (((lh_VS - lh_NS)./(lh_NS)))';
rh_NS_VS_ave = (((rh_VS - rh_NS)./(rh_NS)))';

% .. and save as images in .mgz
lh_NS_VS_ave_img=img;
rh_NS_VS_ave_img=img;

lh_NS_VS_ave_img.vol=lh_NS_VS_ave;
rh_NS_VS_ave_img.vol=rh_NS_VS_ave;

MRIwrite(lh_NS_VS_ave_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_lh_stimEffect_NS_VS_ave_noTIN_noSmooth.mgz');
MRIwrite(rh_NS_VS_ave_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/noSmooth/ALFF_rh_stimEffect_NS_VS_ave_noTIN_noSmooth.mgz');
