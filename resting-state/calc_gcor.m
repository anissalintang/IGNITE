% GCOR function to calculate whole-brain

function calc_gcor(varargin)

    if nargin<=1
        error('Not enough input variables')
    elseif nargin<=2
        error('Not enough input variables')
    elseif nargin<=3
        error('Not enough input variables')
    elseif nargin<=4
        data = varargin{1};
        opt = varargin{2};
        GCOR_lh_map_out = varargin{3};
        GCOR_rh_map_out = varargin{4};

        % Load the data
        unitVar_data = MRIread(data);
        unitVar_data_size = size(unitVar_data.vol);

        U = squeeze(unitVar_data.vol);

        % Transpose the data matrix to have timepoints in rows and voxels in columns
        U = U';

        num_cols = size(U, 2);
        U_lh = U(:, 1:num_cols/2);
        U_rh = U(:, (num_cols/2 + 1):num_cols);

        % get g (average of all unit variance time series) == mean of each
        % row == mean of all voxels across time points
        g_lh = mean(U_lh,2,"omitnan");
        g_rh = mean(U_rh,2,"omitnan");
        g_all = mean (U,2,"omitnan");

        N_lh = size(U_lh,1); % Number of all timepoints
        N_rh = size(U_rh,1); % Number of all timepoints

        M_lh = size(U_lh,2); % Number of all vertices
        M_rh = size(U_rh,2); % Number of all vertices

        if strcmp(opt,'same')
            % GCOR calculation
            data_reshaped_lh=zeros(1,M_lh);
            GCOR_lh = 1/ N_lh * U_lh' * g_lh;

            data_reshaped_rh=zeros(1,M_rh);
            GCOR_rh = 1/ N_rh * U_rh' * g_rh;

            temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg_onlh_fssym.mgz');
            temp.nframes = 1;
            data_reshaped_lh = GCOR_lh';
            data_reshaped_lh_out=temp;
            data_reshaped_lh_out.vol=data_reshaped_lh;
            MRIwrite(data_reshaped_lh_out, GCOR_lh_map_out);

            temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg_onlh_fssym.mgz');
            temp.nframes = 1;
            data_reshaped_rh = GCOR_rh';
            data_reshaped_rh_out=temp;
            data_reshaped_rh_out.vol=data_reshaped_rh;
            MRIwrite(data_reshaped_rh_out, GCOR_rh_map_out);

        elseif strcmp(opt,'across')
            % GCOR calculation
            data_reshaped_lh=zeros(1,M_lh);
            GCOR_lh = 1/ N_lh * U_lh' * g_rh;

            data_reshaped_rh=zeros(1,M_rh);
            GCOR_rh = 1/ N_rh * U_rh' * g_lh;

            temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg_onlh_fssym.mgz');
            temp.nframes = 1;
            data_reshaped_lh = GCOR_lh';
            data_reshaped_lh_out=temp;
            data_reshaped_lh_out.vol=data_reshaped_lh;
            MRIwrite(data_reshaped_lh_out, GCOR_lh_map_out);

            temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg_onlh_fssym.mgz');
            temp.nframes = 1;
            data_reshaped_rh = GCOR_rh';
            data_reshaped_rh_out=temp;
            data_reshaped_rh_out.vol=data_reshaped_rh;
            MRIwrite(data_reshaped_rh_out, GCOR_rh_map_out);

        elseif strcmp(opt,'all')
            % GCOR calculation
            data_reshaped_lh=zeros(1,M_lh);
            GCOR_lh = 1/ N_lh * U_lh' * g_all;

            data_reshaped_rh=zeros(1,M_rh);
            GCOR_rh = 1/ N_rh * U_rh' * g_all;
    
            temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_lh_filt01_fsavg_onlh_fssym.mgz');
            temp.nframes = 1;
            data_reshaped_lh = GCOR_lh';
            data_reshaped_lh_out=temp;
            data_reshaped_lh_out.vol=data_reshaped_lh;
            MRIwrite(data_reshaped_lh_out, GCOR_lh_map_out);

            temp = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/IGNTBP_00072/IGNTBP_00072_rh_filt01_fsavg_onlh_fssym.mgz');
            temp.nframes = 1;
            data_reshaped_rh = GCOR_rh';
            data_reshaped_rh_out=temp;
            data_reshaped_rh_out.vol=data_reshaped_rh;
            MRIwrite(data_reshaped_rh_out, GCOR_rh_map_out);
        
    
    end
end