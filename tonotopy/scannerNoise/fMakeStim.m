function [stim,band] = fMakeStim(NConds,NReps,LEV,DUR,NomLev,F1,F2,FS,Phones)

    side = {'left' 'right'};
    DT = 1/FS;        
    
    NPts = round(DUR/DT);
    tim = (0:NPts-1)*DT; 
    Gate = 10;

    N2 = 2^nextpow2(NPts);
    frq = FS*(0:N2/2)/N2; 
        
    % Make equalization filter for S14 inserts;
    pth = fullfile('..','EQU',Phones);
    file = dir(fullfile(pth,'noise*.wav'));

    fnam = struct;
    for I = 1:numel(file)
        for II = 1:numel(side)
            if contains(file(I).name,side{II})
                fnam.(side{II}) = fullfile(pth,file(I).name);
            end
        end
    end

    p1 = struct; 
    equ = struct;
    for I = 1:numel(side)    
        noi = audioread(fnam.(side{I}))'; % load calibration files;
        info = audioinfo(fnam.(side{I}));

        FS0 = info.SampleRate/1000;
        N20 = info.TotalSamples;
                    
        % divide signals into shorter segments, such that fft frequency resolution of each segment equals 5 Hz; 
        M = floor(FS0/(5/1000));
        idx = cell(1,floor(N20/M));
        for II = 1:numel(idx)
            idx{II} = (II-1)*M+1:II*M;
        end  

        % calculate segment spectra;
        M = 2^nextpow2(M);
        frq0 = FS0*(0:M/2)/M; % segment frequency axis; 

        P1 = cell(size(idx));
        for II = 1:numel(idx)    
            Y = fft(noi(idx{II})-mean(noi(idx{II})),M);             
            P2 = abs(Y)/sqrt(M); % two-sided magnitude spectrum; 
            P1{II} = P2(1:M/2+1); % single-sided magnitude spectrum;
            P1{II}(2:end-1) = 2*P1{II}(2:end-1);
        end
        p1.(side{I}) = mean(cell2mat(P1'));
        p1.(side{I}) = smoothdata(p1.(side{I}),'movmean',50);
        
        equ.(side{I}) = 1./p1.(side{I});
        equ.(side{I})(or(frq0<F1,frq0>F2)) = nan; 
        equ.(side{I}) = interp1(f2nerb(frq0),equ.(side{I}),f2nerb(frq),'linear');  
        [~,IDX] = min(abs(frq-1));
        equ.(side{I}) = equ.(side{I})/equ.(side{I})(IDX);
        equ.(side{I})(isnan(equ.(side{I}))) = 0; 
    end

    nerb = f2nerb(F1):(f2nerb(F2)-f2nerb(F1))/NConds:f2nerb(F2); % edges of stimulus bands;
    bp = cell(1,NConds);
    band = cell(1,NConds);
    for I = 1:NConds
        bp{I} = zeros(size(frq)); bp{I}(and(frq>=nerb2f(nerb(I)),frq<=nerb2f(nerb(I+1)))) = 1;
        bp{I} = bp{I}/sqrt(mean(bp{I}.^2));
        band{I} = [nerb2f(nerb(I)) nerb2f(nerb(I+1))];
    end

    % A-weighting filter;
    f = @(x) 12194^2*(x*1000).^4./(((x*1000).^2+20.6^2).*sqrt(((x*1000).^2+107.7^2).*((x*1000).^2+737.9^2)).*((x*1000).^2+12194^2));
    ra = f(1)./f(frq); ra(or(frq<F1,frq>F2)) = 0;

    stim = struct; stim.t = tim; stim.f = frq;
    stim.wf = cell(NConds,NReps);
    for I = 1:NReps
        % filter noise;
        noi = randn(1,N2); noi = noi/sqrt(mean(noi.^2)); NOI = fft(noi); 
        for II = 1:NConds
            env = fmorse(tim,Gate); % Morse-code envelope;
            stim.wf{II,I} = zeros(numel(side),NPts);
            for III = 1:numel(side)
                flt = equ.(side{III}).*bp{II}.*ra; 
                tmp = real(ifft([flt fliplr(flt(2:end-1))].*NOI));                
                stim.wf{II,I}(III,:) = tmp(1:NPts).*env*10^((LEV-NomLev(III))/20);
            end
        end
    end
            
    stim.spc = cell(1,NConds);
    for I = 1:NConds
        stim.spc{I} = abs(fft(stim.wf{I,1}(1,:),N2))/sqrt(N2); 
        stim.spc{I} = stim.spc{I}(1:N2/2+1); stim.spc{I}(2:end-1) = 2*stim.spc{I}(2:end-1); 
    end
end
