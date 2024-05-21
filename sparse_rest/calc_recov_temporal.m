%% recov function to calculate for entire time series

function calc_recov_temporal(varargin)

    if nargin<3
        error('Not enough input variables')
    else
        data = varargin{1};
        recov_lh_map_out = varargin{2};
        recov_rh_map_out = varargin{3};

        maskleft = ('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh.mgh');
        maskright = ('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_rh.mgh');

        % Load the data
        recov_data = MRIread(data);
        recov_data_size = size(recov_data.vol);

        maskleft_data=MRIread(maskleft);
        maskleft_vol = maskleft_data.vol;

        maskright_data=MRIread(maskright);
        maskright_vol = maskright_data.vol;

        U = squeeze(recov_data.vol);

        % Transpose the data matrix to have timepoints in rows and voxels in columns
        U = U';
        
        % Create a logical vector that identifies the voxels within the mask
        maskleft_vector = maskleft_vol > 0;
        maskright_vector = maskright_vol > 0;

        num_cols = size(U, 2);
        U_lh = U(:, 1:num_cols/2);
        U_rh = U(:, (num_cols/2 + 1):num_cols);

        % Reduce data to only include mask voxels
        U_lh_mask = U_lh(:, maskleft_vector(1:num_cols/2));
        U_rh_mask = U_rh(:, maskright_vector(1:num_cols/2));
       
        % Calculate recov for every vertex in the mask for each hemisphere
        recov_lh = calc_recov(U_lh, U_lh_mask);
        recov_rh = calc_recov(U_rh, U_rh_mask);

        % Save recov data
        save_recov_data(recov_lh, recov_lh_map_out, 'lh');
        save_recov_data(recov_rh, recov_rh_map_out, 'rh');

    end
end

function recov = calc_recov(U, U_mask)
    recov = [];
    g = mean(U_mask, 2, 'omitnan');
    N = size(g, 1);
    for i = 1:size(U, 2)
        recov = [recov, 1 / N * U(:, i)' * g];
    end
end

function save_recov_data(recov_vol, recov_map_out, hemisphere)
    if strcmp(hemisphere, 'lh')
        temp = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg.mgz');
    elseif strcmp(hemisphere, 'rh')
        temp = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg.mgz');
    else
        error('Invalid hemisphere. Must be ''lh'' or ''rh''.')
    end
    
    temp.nframes = 1;
    data_reshaped = recov_vol';
    data_reshaped_out=temp;
    data_reshaped_out.vol=data_reshaped;
    MRIwrite(data_reshaped_out, recov_map_out);
end
