function read_logfiles(filename, pathout)
% filename="/Volumes/gdrive4tb/IGNITE/data/Tonotopy_log/IGNTFA_00065/IGNTFA_00065_16-Sep-2022.txt";
% pathout="/Volumes/gdrive4tb/IGNITE/tonotopy/glm/IGNTFA_00065/logFiles/";

    % Open the file for reading
    fid = fopen(filename, 'r');
    
    % Skip the first line (playTono.m date and time)
    fgetl(fid);
    
    % Read NConds
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'NConds = (\d+)', 'tokens');
    NConds = str2double(tokens{1}{1});
    
    % Read NSils
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'NSils = (\d+)', 'tokens');
    NSils = str2double(tokens{1}{1});
    
    % Read NReps
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'NReps = (\d+)', 'tokens');
    NReps = str2double(tokens{1}{1});
    
    % Read NDummy
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'NDummy = (\d+)', 'tokens');
    NDummy = str2double(tokens{1}{1});
    
    % Read TA
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'TA = ([\d\.]+) s', 'tokens');
    TA = str2double(tokens{1}{1});
    
    % Read DUR
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'DUR = ([\d\.]+) s', 'tokens');
    DUR = str2double(tokens{1}{1});

    % Read TR
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'TR = ([\d\.]+) s', 'tokens');
    TR = str2double(tokens{1}{1});

    % Read LEV
    line = fgetl(fid);
    while isempty(line)
        line = fgetl(fid);
    end
    tokens = regexp(line, 'LEV = ([\d\.]+) dBA', 'tokens');
    LEV = str2double(tokens{1}{1});
    
    seq = cell((NConds + NSils) * NReps, 1);
    ev = struct;
    
    % Initialize counters for each events
    events = ["band1", "band2", "band3", "band4", "band5", "band6", "band7", "band8", "silence"];
    conditions = ["rest_band1", "rest_band2", "rest_band3", "rest_band4", "rest_band5", "rest_band6", "rest_band7", "rest_band8", "rest_silence", ...
                       "vis_band1", "vis_band2", "vis_band3", "vis_band4", "vis_band5", "vis_band6", "vis_band7", "vis_band8", "vis_silence"];
    for cond = events
        counters.(cond) = 0;
        ev.e8.(cond) = zeros(NReps, 3); % 8x3 matrix for each condition
    end
    
    for cond = conditions
        counters.(cond) = 0;
        ev.e16.(cond) = zeros(NReps/2, 3);  % Initialize with half the repetitions
    end


    % Calculate the correction for sparse timing
    correction = (TR/2) - (TA/2);
    firstOnsetTime = (17+correction) - 22.5; % 17 is the E time 2sec after thrid vol, 22.5 is the length of three dummies
%     firstOnsetTime = 17;

    realCounter = 0;
    % Read the sequence of events and calculate timings
    for i = 1:(NConds + NSils) * NReps
        line = fgetl(fid);
        while isempty(line)
            line = fgetl(fid);
        end
        seq{i} = line;
        eventName = seq{i};
        
        % Calculate the onset time for this event
        if i==1
            onsetTime =  firstOnsetTime;
        else
            onsetTime =  onsetTime + 7.5;
        end
        
        
        % For ev.e8, not considering visual conditions
        counters.(eventName) = counters.(eventName) + 1;
        ev.e8.(eventName)(counters.(eventName), :) = [onsetTime, DUR, 1];
        
        % For ev.e16, considering both visual conditions
        if realCounter < 20 || (realCounter >= 40 && realCounter < 60) % rest condition blocks
            extendedEventName = ['rest_' eventName];
        else % vis condition blocks
            extendedEventName = ['vis_' eventName];
        end

        counters.(extendedEventName) = counters.(extendedEventName) + 1;
        ev.e16.(extendedEventName)(counters.(extendedEventName), :) = [onsetTime, DUR, 1];
        
        % Increment the scanCounter and realCounter
        realCounter = realCounter + 1;
    end


    % Save each field of ev as a .txt file
    fields = fieldnames(ev.e8);
    for i = 1:length(fields)
        fieldname = fields{i};
        data = ev.e8.(fieldname);

        % Ensure the directory exists
        outdir = fullfile(pathout, '8');
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end
        
        % Open a new .txt file for writing
        fidd = fopen(fullfile(pathout, '8', sprintf('%s.txt', fieldname)), 'w');
        
        % Write the content of the field to the file
        for j = 1:size(data, 1)
            fprintf(fidd, '%f\t%f\t%f\n', data(j, 1), data(j, 2), data(j, 3));
        end
        
        % Close the file
        fclose(fidd);
    end

    fields = fieldnames(ev.e16);
    for i = 1:length(fields)
        fieldname = fields{i};
        data = ev.e16.(fieldname);

        % Ensure the directory exists
        outdir = fullfile(pathout, '16');
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end
        
        % Open a new .txt file for writing
        fidd = fopen(fullfile(pathout, '16', sprintf('%s.txt', fieldname)), 'w');
        
        % Write the content of the field to the file
        for j = 1:size(data, 1)
            fprintf(fidd, '%f\t%f\t%f\n', data(j, 1), data(j, 2), data(j, 3));
        end
        
        % Close the file
        fclose(fidd);
    end

    % Save seq and event structures;      
    save(fullfile(pathout,'sequence.mat'),'NConds','NSils','NReps','NDummy','TA','DUR','TR','LEV','ev','seq')

    % Close the file
    fclose(fid);
end
