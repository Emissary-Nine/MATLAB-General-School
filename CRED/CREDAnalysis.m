clear;
close all;

folder = "(CRED DATA)";
files = dir(fullfile(folder,"*.txt"));

tables = cell(numel(files),1);
names  = strings(numel(files),1);
for k = 1:numel(files)
    fname = fullfile(folder, files(k).name);
    tables{k} = readtable(fname);   
    names(k) = files(k).name;
end

for k = 1:18 %Change value to change file range
    currentTable = tables{k};
    meanValue = mean(currentTable{:, 2}); 
    % fprintf('Mean voltage in one spring impulse trial %d : %.2f\n', k, meanValue);
    stdValue = std(currentTable{:, 2},1);
    % fprintf('Std deviation of voltage in one spring impulse trial %d : %.2f\n', k, stdValue);
    voltageCount = currentTable{:, 2};
        %rangeValue = range(voltageCount,2); <--- fix later
    rngTest = max(voltageCount) - min(voltageCount);
    fprintf('Range of voltage in one spring impulse trial %d : %.2f\n', k, rngTest);
       %Find time from base to peak and avg it
       
   Time_s_ = currentTable{: , 1};
   Voltage_V_ = currentTable{:, 2};
   
   [pks, locs, width, p] = findpeaks(Voltage_V_,Time_s_,MinPeakProminence=1); % Peak
   [vks,vlocs,vwidth, vp] = findpeaks(-Voltage_V_,Time_s_,MinPeakProminence=1); % Base
       
    minPVdist = 0.1;   % seconds (minimum)
    maxPVdist = 1.2;   % seconds (maximum)

        paired_pks   = [];
        paired_vks   = [];
        paired_ploc  = [];
        paired_vloc  = [];

% Limit peaks / base, refine selection

            for i = 1:length(locs)
                
                dt = locs(i) - vlocs;
                dt(dt <= 0) = inf;
            
                [dtmin, idx] = min(dt);
            
                if dtmin >= minPVdist && dtmin <= maxPVdist
                    paired_pks  = [paired_pks;  pks(i)];
                    paired_vks  = [paired_vks;  vks(idx)];
                    paired_ploc = [paired_ploc; locs(i)];
                    paired_vloc = [paired_vloc; vlocs(idx)];
                end
            end

   % Calculate time from valley to peak for all peaks
        
            for j = 1:length(paired_vloc)
            
                timeV2POneSImpulse{j,k} = paired_ploc(j) - paired_vloc(j);
                
            end

    if (0<k) && (k<4)

            figure
            plot(currentTable,"Time_s_","Voltage_V_");
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('One Spring Impulse Calf Raise V vs T, Trial %d', k));
            hold on
            plot(paired_ploc,paired_pks,'ro',MarkerSize=8);
            plot(paired_vloc,-paired_vks,'go',MarkerSize=8);
            hold off
    end

end