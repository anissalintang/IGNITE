%% ReCov function to calculate whole-brain

function calc_recov(varargin)

    if nargin<=1
        error('Not enough input variables')
    elseif nargin<=2
        error('Not enough input variables')
    elseif nargin<=3
        error('Not enough input variables')
    elseif nargin<=4
        data = varargin{1};
        rad = varargin{2};
        recov_lh_map_out = varargin{3};
        recov_rh_map_out = varargin{4};
      
        load('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReCov/surf_lh.mat');
        load('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReCov/surf_rh.mat');

        % Load the data
        recov_data = MRIread(data);
        recov_data_size = size(recov_data.vol);

        U = squeeze(recov_data.vol);

        % Transpose the data matrix to have timepoints in rows and voxels in columns
        U = U';
        
        IDX = size(U, 2)/2;

        num_cols = size(U, 2);
        U_lh = U(:, 1:num_cols/2);
        U_rh = U(:, (num_cols/2 + 1):num_cols);
        
       
        %%
        recov_lh = [];
        for i=1:IDX
            idx_lh = nearest(surf_lh.graph,i,rad);
            
            % get g (average of all unit variance time series) == mean of each
            % row == mean of all voxels across time points
            g_lh = mean(U_lh(:,idx_lh),2,'omitnan');

            % ReCov calculation
            M_lh = size(idx_lh,1); % Number of all voxels inside neighborhood
            N_lh = size(g_lh,1); % Number of all timepoints
            
            recov_lh = [recov_lh, 1/ N_lh * U_lh(:,i)' * g_lh];
                    
        end

        recov_rh = [];
        for i=1:IDX
            idx_rh = nearest(surf_rh.graph,i,rad);
            g_rh = mean(U_rh(:,idx_rh),2,'omitnan');

            % ReCov calculation
            M_rh = size(idx_rh,1); % Number of all voxels inside neighborhood
            N_rh = size(g_rh,1); % Number of all timepoints
            
            recov_rh = [recov_rh, 1/ N_rh * U_rh(:,i)' * g_rh];
                    
        end

        temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg.mgz');
        temp.nframes = 1;
        data_reshaped_lh = recov_lh';
        data_reshaped_lh_out=temp;
        data_reshaped_lh_out.vol=data_reshaped_lh;
        MRIwrite(data_reshaped_lh_out, recov_lh_map_out);
        

        temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg.mgz');
        temp.nframes = 1;
        data_reshaped_rh = recov_rh';
        data_reshaped_rh_out=temp;
        data_reshaped_rh_out.vol=data_reshaped_rh;
        MRIwrite(data_reshaped_rh_out, recov_rh_map_out);
        

    end
end