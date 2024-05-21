function fsmerge(varargin)
% Usage: fsmerge(infile1,infile2,...,infileN,outfile,opt), where opt = 'x',
% 'y', 't';

    if nargin<=3
        error('Not enough input variables')
    else
        infiles = varargin(1:end-2);
        outfile = varargin{end-1};
        opt = varargin{end};
    end
    [outpth,outnam] = ffileparts(outfile); outext = 'mgz';

    vol = [];
    for I = 1:numel(infiles)
        [inpth,innam,inext] = ffileparts(infiles{I});
        if isempty(inext)
            inext = 'mgz'; 
        elseif ~any(strcmp(inext,{'mgh' 'mgz'}))
            error('Input files must be either .mgh or .mgz')            
        end

        tmp = MRIread(fullfile(inpth,[innam '.' inext]));
        if I==1
            mri = tmp;
        end
        switch(opt)
            case('x')
                vol = cat(2,vol,tmp.vol);
            case('y')
                vol = cat(1,vol,tmp.vol);
            case('t')
                vol = cat(4,vol,tmp.vol);
        end
    end
    mri.vol = vol;

    mri.volsize = size(vol);
    mri.height = size(vol,1);
    mri.width = size(vol,2);
    mri.depth = size(vol,3);
    mri.nframes = size(vol,4);

    MRIwrite(mri,fullfile(outpth,[outnam '.' outext]));
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
