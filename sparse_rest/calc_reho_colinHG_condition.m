%% ReHo function to calculate HG from Colin's mask

function calc_reho_colinHG_condition(varargin)

    if nargin<=3
        error('Not enough input variables')
    else
        data = varargin{1};
        reho_lh_map_out_rest = varargin{2};
        reho_rh_map_out_rest = varargin{3};
        reho_lh_map_out_vis = varargin{4};
        reho_rh_map_out_vis = varargin{5};

        maskleft = ('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg/HO_HG_lh_mask_fsavg.mgz');
        maskright = ('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg/HO_HG_rh_mask_fsavg.mgz');

        % Load the data
        reho_data = MRIread(data);
        reho_data_size = size(reho_data.vol);

        maskleft_data=MRIread(maskleft);
        maskleft_vol = maskleft_data.vol;

        maskright_data=MRIread(maskright);
        maskright_vol = maskright_data.vol;

        U = squeeze(reho_data.vol);

        % Transpose the data matrix to have timepoints in rows and voxels in columns
        U = U';
        
        % Create a logical vector that identifies the voxels within the mask
        maskleft_vector = maskleft_vol > 0;
        maskright_vector = maskright_vol > 0;

        IDX = size(U, 2)/2;

        %% 
        num_cols = size(U, 2);
        U_lh = U(:, 1:num_cols/2);
        U_rh = U(:, (num_cols/2 + 1):num_cols);

        % Define rest and vis frames
        rest_frames = [1:20, 41:60];
        vis_frames = [21:40, 61:80];

        % Define U for rest and vis frames
        U_lh_rest = U_lh(rest_frames, :);
        U_rh_rest = U_rh(rest_frames, :);
        U_lh_vis = U_lh(vis_frames, :);
        U_rh_vis = U_rh(vis_frames, :);

        
        % Reduce data to only include mask voxels and separate by condition
        U_lh_mask_rest = U_lh(rest_frames, maskleft_vector(1:num_cols/2));
        U_rh_mask_rest = U_rh(rest_frames, maskright_vector(1:num_cols/2));
        U_lh_mask_vis = U_lh(vis_frames, maskleft_vector(1:num_cols/2));
        U_rh_mask_vis = U_rh(vis_frames, maskright_vector(1:num_cols/2));
       
        % Calculate ReHo for every vertex in the mask separately for each condition and hemisphere
        reho_lh_rest = calc_reho_for_condition(U_lh_rest, U_lh_mask_rest);
        reho_rh_rest = calc_reho_for_condition(U_rh_rest, U_rh_mask_rest);
        reho_lh_vis = calc_reho_for_condition(U_lh_vis, U_lh_mask_vis);
        reho_rh_vis = calc_reho_for_condition(U_rh_vis, U_rh_mask_vis);

        % Save ReHo data for rest condition
        save_reho_data(reho_lh_rest, reho_lh_map_out_rest, 'lh');
        save_reho_data(reho_rh_rest, reho_rh_map_out_rest, 'rh');

        % Save ReHo data for vis condition
        save_reho_data(reho_lh_vis, reho_lh_map_out_vis, 'lh');
        save_reho_data(reho_rh_vis, reho_rh_map_out_vis, 'rh');

    end
end

function reho_condition = calc_reho_for_condition(U_condition, U_mask_condition)
    reho_condition = [];
    g = mean(U_mask_condition, 2, 'omitnan');
    N = size(g, 1);
    for i = 1:size(U_condition, 2)
        reho_condition = [reho_condition, 1 / N * U_condition(:, i)' * g];
    end
end


function save_reho_data(reho_vol, reho_map_out, hemisphere)
    if strcmp(hemisphere, 'lh')
        temp = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg_onlh_fssym.mgz');
    elseif strcmp(hemisphere, 'rh')
        temp = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg_onlh_fssym.mgz');
    else
        error('Invalid hemisphere. Must be ''lh'' or ''rh''.')
    end
    
    temp.nframes = 1;
    data_reshaped = reho_vol';
    data_reshaped_out=temp;
    data_reshaped_out.vol=data_reshaped;
    MRIwrite(data_reshaped_out, reho_map_out);
end
