function stats = fsstats(varargin)

    if nargin<=1
        error('Not enough input variables')
    elseif nargin<=2
        infile = varargin{1};
        options = varargin{2};
    elseif nargin>=3
        infile = varargin{1};
        options = varargin{2};
        maskfile = varargin{3};
    end

    [inpth,innam,inext] = ffileparts(infile);
    if isempty(inext)
        inext = '.mgz'; 
    elseif ~any(strcmp(inext,{'mgh' 'mgz'}))
        error('Input file must be either .mgh or .mgz')            
    end

    mri = MRIread(fullfile(inpth,[innam '.' inext]));
    if exist("maskfile",'var')
        [mpth,mnam,mext] = ffileparts(maskfile);
        if isempty(mext)
            mext = '.mgz'; 
        elseif ~any(strcmp(mext,{'mgh' 'mgz'}))
            error('Mask file must be either .mgh or .mgz')            
        end
        tmp = MRIread(fullfile(mpth,[mnam '.' mext]));
        mask = tmp.vol;
        clear tmp
        mri.vol = mri.vol(find(mask));
    end
    
    if contains(options,'-u')
        THR = sscanf(options,'-u %g');
        mri.vol = mri.vol(find(mri.vol>=THR));
    end
    if contains(options,'-l')
        THR = sscanf(options,'-l %g');
        mri.vol = mri.vol(find(mri.vol<=THR));
    end

    idx = find(mri.vol>0);

    if contains(options,'-r')
        stats = [prctile(mri.vol,2) prctile(mri.vol,98)];
    elseif contains(options,'-R')
        stats = [min(mri.vol) max(mri.vol)];
    elseif contains(options,'-e')
        stats = mean(-mri.vol.*log(mri.vol));
    elseif contains(options,'-E')
        stats = mean(-mri.vol(idx).*log(mri.vol(idx)));
    elseif contains(options,'-v')
        stats = numel(mri.vol);      
    elseif contains(options,'-V')
        stats = numel(mri.vol(idx));        
    elseif contains(options,'-m')
        stats = mean(mri.vol, 'omitnan');
    elseif contains(options,'-M')
        stats = mean(mri.vol(idx));
    elseif contains(options,'-s')
        stats = std(mri.vol);
    elseif contains(options,'-S')
        stats = std(mri.vol(idx));
    elseif contains(options,'-x')
        [~,stats] = max(mri.vol);
    elseif contains(options,'-X')
        [~,stats] = min(mri.vol);
    elseif contains(options,'-p')
        PCT = sscanf(options,'-p %g');
        stats = prctile(mri.vol,PCT);
    elseif contains(options,'-P')
        PCT = sscanf(options,'-P %g');
        stats = prctile(mri.vol(idx),PCT);
    end
end

function [pth,nam,ext] = ffileparts(file)
        
    idx = strfind(file,filesep);

    if ~isempty(idx)
        pth = file(1:idx(end)-1);
        file = file(idx(end)+1:end);
    else
        pth = '';
    end

    idx = strfind(file,'.');
    if ~isempty(idx)
        nam = file(1:idx(end)-1);
        ext = file(idx(end)+1:end);
    else
        nam = file;
        ext = '';
    end
end


        

        
        