clc
clear all
close all

imgorig= MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGTTKA_00017/IGTTKA_00017_sparse_tono_orig.nii.gz');
imgpe0= MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGTTKA_00017/IGTTKA_00017_sparse_tono_pe0.nii.gz');
imgpe1= MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGTTKA_00017/IGTTKA_00017_sparse_tono_pe1.nii.gz');


goodimgorig=MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGNTFA_00065/IGNTFA_00065_sparse_tono_orig.nii.gz');
goodimgpe0=MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGNTFA_00065/IGNTFA_00065_sparse_tono_pe0.nii.gz');
goodimgpe1=MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGNTFA_00065/IGNTFA_00065_sparse_tono_pe1.nii.gz');
%% from the bad image
% visualise sag, cor, and axial of badimg
% Define the slice numbers you want to visualize
slice_nums_x = round(linspace(1, size(imgorig.vol, 1), 3));  % sagittal slices
slice_nums_y = round(linspace(1, size(imgorig.vol, 2), 3));  % coronal slices
slice_nums_z = round(linspace(1, size(imgorig.vol, 3), 3));  % axial slices

% Create a new figure
figure;

% Plot coronal slices
for i = 1:length(slice_nums_x)
    subplot(3, length(slice_nums_x), i);
    slice = squeeze(imgorig.vol(slice_nums_x(i), :, :, 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('coronal slice %d', slice_nums_x(i)));
end

% Plot sagittal slices
for i = 1:length(slice_nums_y)
    subplot(3, length(slice_nums_y), length(slice_nums_y) + i);
    slice = squeeze(imgorig.vol(:, slice_nums_y(i), :, 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('sagittal slice %d', slice_nums_y(i)));
end

% Plot axial slices
for i = 1:length(slice_nums_z)
    subplot(3, length(slice_nums_z), 2 * length(slice_nums_z) + i);
    slice = squeeze(imgorig.vol(:, :, slice_nums_z(i), 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Axial slice %d', slice_nums_z(i)));
end

% Add a colorbar to the figure
colorbar;

%% from the good image
% visualise sag, cor, and axial of badimg
% Define the slice numbers you want to visualize
slice_nums_x = round(linspace(1, size(goodimgorig.vol, 1), 3));  % sagittal slices
slice_nums_y = round(linspace(1, size(goodimgorig.vol, 2), 3));  % coronal slices
slice_nums_z = round(linspace(1, size(goodimgorig.vol, 3), 3));  % axial slices


% Create a new figure
figure;

% Plot coronal slices
for i = 1:length(slice_nums_x)
    subplot(3, length(slice_nums_x), i);
    slice = squeeze(goodimgorig.vol(slice_nums_x(i), :, :, 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Coronal slice %d', slice_nums_x(i)));
end

% Plot Sagittal slices
for i = 1:length(slice_nums_y)
    subplot(3, length(slice_nums_y), length(slice_nums_y) + i);
    slice = squeeze(goodimgorig.vol(:, slice_nums_y(i), :, 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Sagittal slice %d', slice_nums_y(i)));
end

% Plot axial slices
for i = 1:length(slice_nums_z)
    subplot(3, length(slice_nums_z), 2 * length(slice_nums_z) + i);
    slice = squeeze(goodimgorig.vol(:, :, slice_nums_z(i), 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Axial slice %d', slice_nums_z(i)));
end

% Add a colorbar to the figure
colorbar;

%% badimg flip
% Create a new 4D matrix with the same size as your original data
flipped_imgorig = zeros(size(imgorig.vol));
flipped_imgpe0 = zeros(size(imgpe0.vol));
flipped_imgpe1 = zeros(size(imgpe0.vol));

% Loop over the fourth dimension (time) --imgorig
for t = 1:size(imgorig.vol, 4)
    % Extract the volume at this timepoint
    volume = imgorig.vol(:,:,:,t);
    
    % Flip the volume along the x, y, and z axes
    flipped_volume = flip(flip(flip(volume, 1), 2), 3);
    
    % Store the flipped volume in the new 4D matrix
    flipped_imgorig(:,:,:,t) = flipped_volume;
end

% Loop over the fourth dimension (time) --imgpe0
for t = 1:size(imgpe0.vol, 4)
    % Extract the volume at this timepoint
    volume = imgpe0.vol(:,:,:,t);
    
    % Flip the volume along the x, y, and z axes
    flipped_volume = flip(flip(flip(volume, 1), 2), 3);
    
    % Store the flipped volume in the new 4D matrix
    flipped_imgpe0(:,:,:,t) = flipped_volume;
end

% Loop over the fourth dimension (time) --imgpe1
for t = 1:size(imgpe1.vol, 4)
    % Extract the volume at this timepoint
    volume = imgpe1.vol(:,:,:,t);
    
    % Flip the volume along the x, y, and z axes
    flipped_volume = flip(flip(flip(volume, 1), 2), 3);
    
    % Store the flipped volume in the new 4D matrix
    flipped_imgpe1(:,:,:,t) = flipped_volume;
end


%% badimg flipped
% visualise sag, cor, and axial of badimg
% Define the slice numbers you want to visualize
slice_nums_x = round(linspace(1, size(flipped_imgorig, 1), 3));  % sagittal slices
slice_nums_y = round(linspace(1, size(flipped_imgorig, 2), 3));  % coronal slices
slice_nums_z = round(linspace(1, size(flipped_imgorig, 3), 3));  % axial slices

% Create a new figure
figure;

% Plot Coronal slices
for i = 1:length(slice_nums_x)
    subplot(3, length(slice_nums_x), i);
    slice = squeeze(flipped_imgorig(slice_nums_x(i), :, :, 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Coronal slice %d', slice_nums_x(i)));
end

% Plot Sagittal slices
for i = 1:length(slice_nums_y)
    subplot(3, length(slice_nums_y), length(slice_nums_y) + i);
    slice = squeeze(flipped_imgorig(:, slice_nums_y(i), :, 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Sagittal slice %d', slice_nums_y(i)));
end

% Plot axial slices
for i = 1:length(slice_nums_z)
    subplot(3, length(slice_nums_z), 2 * length(slice_nums_z) + i);
    slice = squeeze(flipped_imgorig(:, :, slice_nums_z(i), 1));
    imagesc(slice);
    axis image off;
    colormap(gray);
    title(sprintf('Axial slice %d', slice_nums_z(i)));
end

% Add a colorbar to the figure
colorbar;

%%
% Create a copy of the original MRI struct
flipped_imgorig_struct = goodimgorig;
flipped_imgpe0_struct = goodimgpe0;
flipped_imgpe1_struct = goodimgpe1;

% Replace the 'vol' field with your flipped image data
flipped_imgorig_struct.vol = flipped_imgorig;
flipped_imgpe0_struct.vol = flipped_imgpe0;
flipped_imgpe1_struct.vol = flipped_imgpe1;

% Write the new image data to a NIfTI file
MRIwrite(flipped_imgorig_struct, '/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGTTKA_00017/IGTTKA_00017_sparse_tono_orig.nii.gz');
MRIwrite(flipped_imgpe0_struct, '/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGTTKA_00017/IGTTKA_00017_sparse_tono_pe0.nii.gz');
MRIwrite(flipped_imgpe1_struct, '/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed/IGTTKA_00017/IGTTKA_00017_sparse_tono_pe1.nii.gz');




















