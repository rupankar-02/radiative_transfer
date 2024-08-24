tic;
close all;
clear;
clc;

fluxes = [];
dlav21 = [];

% Load your dataset
load C:/Users/2022r/Desktop/radiative_transfer/input_sbdart.mat;  % Replace with the actual file path

% Set constants and initial values
lat = 8.5241;
lon = 76.9356;
dy = 79;
alat = lat;
alon = lon;
uw = 1.5;
uo3 = 2477.5 * 0.001;
zpres = 100 * 0.001;
wl = 0.550;

% Loop through the dataset
for i = 1:size(dataset, 1)
    aod = dataset(i, 1);
    alpha = dataset(i, 2);
    ssa = dataset(i, 3);
    asy = dataset(i, 4);
    
    fn_input = sprintf('text_file_to_store_inputs_%d.txt', i);
    
    % Calculate time from sunrise and sunset
    [rs, ~, ~, ~, ~, ~] = suncycle(lat, lon, dy);
    p = [];
    t = rs(1);
    for ii = 1:24
        t = t + 0.5;
        if t >= 24
            t = t - 24;
        end
        p = [p, t];
    end
    ind = find(p(12:end) >= rs(2));
    p = [rs(1); p(1:ind(1) + 11)];
    
    % Initialize accumulators
    c = 0;
    TOA = [];
    SUR = [];
    ATM = [];
    
    % Time loop
    for j = 1:length(p)
        time = p(j);
        c = c + 1;
        islab = 6;
        
        %% Input file creation without aerosol
        fid = fopen('INPUT', 'w');
        fprintf(fid, '$INPUT\n');
        fprintf(fid, 'iday=%3d,\n', dy);
        fprintf(fid, 'time=%2f,\n', time);
        fprintf(fid, 'alat=%2f,alon=%2f\n', alat, alon);
        fprintf(fid, 'wlinf=0.25,\nwlsup=4.0,\nwlinc=0.005\n');
        fprintf(fid, 'idatm=1,\nisat=0,\nuw=%2f,\nuo3=%2f\n', uw, uo3);
        fprintf(fid, 'zpres=%2f\n', zpres);
        fprintf(fid, 'islab=%d\n', islab);
        fprintf(fid, '$END\n');
        fclose(fid);
        
        % Run SBDART without aerosol
        system('sbdart.exe >> noaerosols_sw.txt');
        pause(0.15);
        data1 = load('noaerosols_sw.txt');
        num1 = size(data1, 1);
        pure_flux = data1(num1, :);
        
        %% Input file creation with aerosol
        fid = fopen('INPUT', 'w');
        fprintf(fid, '$INPUT\n');
        fprintf(fid, 'iday=%3d,\n', dy);
        fprintf(fid, 'time=%2f,\n', time);
        fprintf(fid, 'alat=%2f,alon=%2f\n', alat, alon);
        fprintf(fid, 'wlinf=0.25,\nwlsup=4.0,\nwlinc=0.005\n');
        fprintf(fid, 'idatm=1,\nisat=0,\nuw=%2f,\nuo3=%2f\n', uw, uo3);
        fprintf(fid, 'zpres=%2f\n', zpres);
        fprintf(fid, 'iaer=5\n');
        fprintf(fid, 'wlbaer=0.550\n');
        fprintf(fid, 'qaber=%f\n', aod);
        fprintf(fid, 'wbaer=%f\n', ssa);
        fprintf(fid, 'gbaer=%f\n', asy);
        fprintf(fid, 'abaer=%f\n', alpha);
        fprintf(fid, 'islab=%d\n', islab);
        fprintf(fid, '$END\n');
        fclose(fid);
        
        % Run SBDART with aerosol
        system('sbdart.exe >> aerosols_sw.txt');
        pause(0.15);
        data = load('aerosols_sw.txt');
        num = size(data, 1);
        flux = data(num, 1);
        
        fluxes = [fluxes; [lat, lon, pure_flux, flux]];
        TOA(c) = (pure_flux(5) - flux(5));
        SUR(c) = (flux(7) - flux(8)) - (pure_flux(7) - pure_flux(8));
    end
    
    dlav21 = [dlav21; [lat, lon, dy, nansum(TOA)/length(TOA), nansum(SUR)/length(SUR), nansum(ATM)/length(ATM)]];
    
    % Save the INPUT file for each iteration
    copyfile('INPUT', fn_input);
end

% Save the results
save('dlav_new.mat', 'dlav21', '-v7.3');
save('fluxes_new.mat', 'fluxes', '-v7.3');
toc;
