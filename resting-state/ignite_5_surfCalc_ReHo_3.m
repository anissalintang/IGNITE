%% ReHo 2.5

% Loop over the hemispheres
clear
mkdir(fullfile('/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/merge_mean/';

% Define the conditions and hemispheres
conditions = {'ns', 'vs', 'as'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_ReHo_', conditions{cond}, '_', hemispheres{hem}, '_2_5_merged_mean.mgz'];
        
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

% Create the variable of noTask and allTasks in both hemispheres
lh_noTask = lh(1,:);
rh_noTask = rh(1,:);

lh_allTasks = mean(lh(2:3, :), 1);
rh_allTasks = mean(rh(2:3, :), 1);

% Calculate the stimEffect in both hemisphere..
lh_stimEffect = (lh_allTasks - lh_noTask)';
rh_stimEffect = (rh_allTasks - rh_noTask)';

% .. and save as images in .mgz
lh_stimEffect_img=img;
rh_stimEffect_img=img;

lh_stimEffect_img.vol=lh_stimEffect;
rh_stimEffect_img.vol=rh_stimEffect;

MRIwrite(lh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_lh_stimEffect_2_5.mgz');
MRIwrite(rh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_rh_stimEffect_2_5.mgz');

%% ReHo 5

% Loop over the hemispheres
clear
mkdir(fullfile('/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/merge_mean/';

% Define the conditions and hemispheres
conditions = {'ns', 'vs', 'as'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_ReHo_', conditions{cond}, '_', hemispheres{hem}, '_5_merged_mean.mgz'];
        
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

% Create the variable of noTask and allTasks in both hemispheres
lh_noTask = lh(1,:);
rh_noTask = rh(1,:);

lh_allTasks = mean(lh(2:3, :), 1);
rh_allTasks = mean(rh(2:3, :), 1);

% Calculate the stimEffect in both hemisphere..
lh_stimEffect = (lh_allTasks - lh_noTask)';
rh_stimEffect = (rh_allTasks - rh_noTask)';

% .. and save as images in .mgz
lh_stimEffect_img=img;
rh_stimEffect_img=img;

lh_stimEffect_img.vol=lh_stimEffect;
rh_stimEffect_img.vol=rh_stimEffect;

MRIwrite(lh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_lh_stimEffect_5.mgz');
MRIwrite(rh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_rh_stimEffect_5.mgz');

%% ReHo 10

% Loop over the hemispheres
clear
mkdir(fullfile('/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/merge_mean/';

% Define the conditions and hemispheres
conditions = {'ns', 'vs', 'as'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_ReHo_', conditions{cond}, '_', hemispheres{hem}, '_10_merged_mean.mgz'];
        
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

% Create the variable of noTask and allTasks in both hemispheres
lh_noTask = lh(1,:);
rh_noTask = rh(1,:);

lh_allTasks = mean(lh(2:3, :), 1);
rh_allTasks = mean(rh(2:3, :), 1);

% Calculate the stimEffect in both hemisphere..
lh_stimEffect = (lh_allTasks - lh_noTask)';
rh_stimEffect = (rh_allTasks - rh_noTask)';

% .. and save as images in .mgz
lh_stimEffect_img=img;
rh_stimEffect_img=img;

lh_stimEffect_img.vol=lh_stimEffect;
rh_stimEffect_img.vol=rh_stimEffect;

MRIwrite(lh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_lh_stimEffect_10.mgz');
MRIwrite(rh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_rh_stimEffect_10.mgz');

%% ReHo 20

% Loop over the hemispheres
clear
mkdir(fullfile('/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/merge_mean/';

% Define the conditions and hemispheres
conditions = {'ns', 'vs', 'as'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_ReHo_', conditions{cond}, '_', hemispheres{hem}, '_20_merged_mean.mgz'];
        
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

% Create the variable of noTask and allTasks in both hemispheres
lh_noTask = lh(1,:);
rh_noTask = rh(1,:);

lh_allTasks = mean(lh(2:3, :), 1);
rh_allTasks = mean(rh(2:3, :), 1);

% Calculate the stimEffect in both hemisphere..
lh_stimEffect = (lh_allTasks - lh_noTask)';
rh_stimEffect = (rh_allTasks - rh_noTask)';

% .. and save as images in .mgz
lh_stimEffect_img=img;
rh_stimEffect_img=img;

lh_stimEffect_img.vol=lh_stimEffect;
rh_stimEffect_img.vol=rh_stimEffect;

MRIwrite(lh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_lh_stimEffect_20.mgz');
MRIwrite(rh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_rh_stimEffect_20.mgz');

%% ReHo 40

% Loop over the hemispheres
clear
mkdir(fullfile('/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo'), 'stimEffect');
% Define the parent folder where all of the subject folders are located
parent_folder = '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/merge_mean/';

% Define the conditions and hemispheres
conditions = {'ns', 'vs', 'as'};
hemispheres = {'lh', 'rh'};

% Initialize the matrices
lh = [];
rh = [];

for hem = 1:length(hemispheres)
    
    % Loop over the conditions
    for cond = 1:length(conditions)
        
        % Construct the filename
        filename = ['allSubj_ReHo_', conditions{cond}, '_', hemispheres{hem}, '_40_merged_mean.mgz'];
        
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

% Create the variable of noTask and allTasks in both hemispheres
lh_noTask = lh(1,:);
rh_noTask = rh(1,:);

lh_allTasks = mean(lh(2:3, :), 1);
rh_allTasks = mean(rh(2:3, :), 1);

% Calculate the stimEffect in both hemisphere..
lh_stimEffect = (lh_allTasks - lh_noTask)';
rh_stimEffect = (rh_allTasks - rh_noTask)';

% .. and save as images in .mgz
lh_stimEffect_img=img;
rh_stimEffect_img=img;

lh_stimEffect_img.vol=lh_stimEffect;
rh_stimEffect_img.vol=rh_stimEffect;

MRIwrite(lh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_lh_stimEffect_40.mgz');
MRIwrite(rh_stimEffect_img, '/Users/msxar17/brainStates/AnissaSurfaceAnalysis/ReHo/stimEffect/ReHo_rh_stimEffect_40.mgz');