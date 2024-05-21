function nv = fnorm(varargin)

    if nargin>=2
        v = varargin{1};
        DIM = varargin{2};
        nv = sqrt(sum(v.^2,DIM));
    elseif nargin>=1
        v = varargin{1};
        nv = norm(v);
    else
        error('Not enough input arguments')
    end
end