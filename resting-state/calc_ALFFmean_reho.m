%% ALFFmean function to calculate whole-brain

function calc_ALFFmean_reho(varargin)

    if nargin<=1
        error('Not enough input variables')
    elseif nargin<=2
        error('Not enough input variables')
    elseif nargin<=3
        error('Not enough input variables')
    elseif nargin<=4
        data = varargin{1};
        rad = varargin{2};
        reho_lh_map_out = varargin{3};
        reho_rh_map_out = varargin{4};
      
        load('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo/surf_lh.mat');
        load('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo/surf_rh.mat');

        % Load the data
        reho_data = MRIread(data);
        reho_data_size = size(reho_data.vol);

        U = squeeze(reho_data.vol);

        % Transpose the data matrix to have timepoints in rows and voxels in columns
        U = U';
        
        IDX = size(U, 2)/2;

        num_cols = size(U, 2);
        U_lh = U(:, 1:num_cols/2);
        U_rh = U(:, (num_cols/2 + 1):num_cols);
        
       
        %%
        reho_lh = [];
        allfMean_lh = [];
        for i=1:IDX
            idx_lh = nearest(surf_lh.graph,i,rad);
            
            % get g (average of all unit variance time series) == mean of each
            % row == mean of all voxels across time points
            g_lh = mean(U_lh(:,idx_lh),2,'omitnan');

            % ReHo calculation
            M_lh = size(idx_lh,1); % Number of all voxels inside neighborhood
            N_lh = size(g_lh,1); % Number of all timepoints
            
            % reho_lh = [reho_lh, 1/ N_lh * U_lh(:,i)' * g_lh];

            % ALFF mean calculation
            allfMean_lh = [allfMean_lh, std(g_lh)];

        end

        reho_rh = [];
        allfMean_rh = [];
        for i=1:IDX
            idx_rh = nearest(surf_rh.graph,i,rad);
            g_rh = mean(U_rh(:,idx_rh),2,'omitnan');

            % ReHo calculation
            M_rh = size(idx_rh,1); % Number of all voxels inside neighborhood
            N_rh = size(g_rh,1); % Number of all timepoints
            
            % reho_rh = [reho_rh, 1/ N_rh * U_rh(:,i)' * g_rh];

            % ALFF mean calculation
            allfMean_rh = [allfMean_rh, std(g_rh)];        
        end

        temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg.mgz');
        temp.nframes = 1;
        data_reshaped_lh = allfMean_lh';
        data_reshaped_lh_out=temp;
        data_reshaped_lh_out.vol=data_reshaped_lh;
        MRIwrite(data_reshaped_lh_out, reho_lh_map_out);
        

        temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg.mgz');
        temp.nframes = 1;
        data_reshaped_rh = allfMean_rh';
        data_reshaped_rh_out=temp;
        data_reshaped_rh_out.vol=data_reshaped_rh;
        MRIwrite(data_reshaped_rh_out, reho_rh_map_out);
        

    end
end