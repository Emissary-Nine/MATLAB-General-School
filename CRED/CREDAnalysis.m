clear;

folder = "(CRED DATA)";
files = dir(fullfile(folder,"*.txt"));

tables = cell(numel(files),1);
names  = strings(numel(files),1);
for k = 1:numel(files)
    fname = fullfile(folder, files(k).name);
    tables{k} = readtable(fname);   
    names(k) = files(k).name;
end

fid = fopen ('Trial_Data.txt','w');

for k = 1:18 %Change value to change file range
    currentTable = tables{k};
    
       
   Time_s_ = currentTable{: , 1};
   Voltage_V_ = currentTable{:, 2};
   
   [pks, locs, width, p] = findpeaks(Voltage_V_, Time_s_,MinPeakProminence=1,MinPeakDistance=0.5,WidthReference='halfprom'); % Peak
   [vks,vlocs,vwidth, vp] = findpeaks(-Voltage_V_,Time_s_,MinPeakProminence=1.5,MinPeakDistance=0.1,MinPeakWidth=0.01); % Base
       
    minPVdist = 0.01;   % seconds (minimum)
    maxPVdist = 4;   % seconds (maximum)

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
            
                timeV2P{j,k} = paired_ploc(j) - paired_vloc(j);
                
            end

    if (0<k) && (k<4)

         
            
                meanValue = mean(currentTable{:, 2}); 
                fprintf('Mean voltage in one spring impulse trial %d : %.2f\n', k, meanValue);
                fprintf(fid, 'Mean voltage in one spring impulse trial %d : %.2f\n', k, meanValue); % Write to file
                stdValue = std(currentTable{:, 2},1);
                fprintf('Std deviation of voltage in one spring impulse trial %d : %.2f\n', k, stdValue);
                fprintf(fid, 'Std deviation of voltage in one spring impulse trial %d : %.2f\n', k, stdValue); % Write to file
                voltageCount = currentTable{:, 2};
                rngTest = max(voltageCount) - min(voltageCount);
                fprintf('Range of voltage in one spring impulse trial %d : %.2f\n', k, rngTest);
                fprintf(fid, 'Range of voltage in one spring impulse trial %d : %.2f\n', k, rngTest); % Write to file
                %Find time from base to peak and avg it
        fprintf(fid, '-----------------------------------------------------------\n');
           
            fig = figure(k); clf(fig)
            plot(currentTable,"Time_s_","Voltage_V_",'LineWidth',2);
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('One Spring Impulse Calf Raise V vs T, Trial %d', k));
            hold on
            plot(paired_ploc,paired_pks,'r.',MarkerSize=30);
            plot(paired_vloc,-paired_vks,'.',MarkerSize=30);
            plot(meanValue,'-r','LineWidth',20); % Fix mean value
            legend('Measured Voltage','Peak Voltage', 'Base Voltage',Location='northwest');
            hold off

    elseif (3<k) && (k<7)

            fig = figure(k); clf(fig)
            plot(currentTable,"Time_s_","Voltage_V_",'LineWidth',2);
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('One Spring Slow Calf Raise V vs T, Trial %d', k-3));
            hold on
            plot(paired_ploc,paired_pks,'r.',MarkerSize=30);
            plot(paired_vloc,-paired_vks,'.',MarkerSize=30);
            legend('Measured Voltage','Peak Voltage', 'Base Voltage',Location='northwest');
            hold off
                        
                meanValue = mean(currentTable{:, 2}); 
                fprintf(fid, 'Mean voltage in the one spring slow trial %d : %.2f\n', k-3, meanValue);
                stdValue = std(currentTable{:, 2},1);
                fprintf(fid, 'Std deviation of voltage in the one spring slow trial %d : %.2f\n', k-3, stdValue);
                voltageCount = currentTable{:, 2};
                rngTest = max(voltageCount) - min(voltageCount);
                fprintf(fid, 'Range of voltage in the one spring slow trial %d : %.2f\n', k-3, rngTest);
                %Find time from base to peak and avg it
        fprintf(fid, '-----------------------------------------------------------\n');

    elseif (6<k) && (k<10)

            fig = figure(k); clf(fig)
            plot(currentTable,"Time_s_","Voltage_V_",'LineWidth',2);
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('Three Spring Impulsive Calf Raise V vs T, Trial %d', k-6));
            hold on
            plot(paired_ploc,paired_pks,'r.',MarkerSize=30);
            plot(paired_vloc,-paired_vks,'.',MarkerSize=30);
            legend('Measured Voltage','Peak Voltage', 'Base Voltage',Location='northwest');
            hold off
                        
                meanValue = mean(currentTable{:, 2}); 
                fprintf(fid, 'Mean voltage in the three spring impulse trial %d : %.2f\n', k-6, meanValue);
                stdValue = std(currentTable{:, 2},1);
                fprintf(fid, 'Std deviation of voltage in the three spring impulse trial %d : %.2f\n', k-6, stdValue);
                voltageCount = currentTable{:, 2};
                rngTest = max(voltageCount) - min(voltageCount);
                fprintf(fid, 'Range of voltage in the three spring impulse trial %d : %.2f\n', k-6, rngTest);
                %Find time from base to peak and avg it
        fprintf(fid, '-----------------------------------------------------------\n');

    elseif (9<k) && (k<13)

            fig = figure(k); clf(fig)
            plot(currentTable,"Time_s_","Voltage_V_",'LineWidth',2);
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('Three Spring Slow Calf Raise V vs T, Trial %d', k-9));
            hold on
            plot(paired_ploc,paired_pks,'r.',MarkerSize=30);
            plot(paired_vloc,-paired_vks,'.',MarkerSize=30);
            legend('Measured Voltage','Peak Voltage', 'Base Voltage',Location='northwest');
            hold off
                        
                meanValue = mean(currentTable{:, 2}); 
                fprintf(fid, 'Mean voltage in the three spring slow trial %d : %.2f\n', k-9, meanValue);
                stdValue = std(currentTable{:, 2},1);
                fprintf(fid, 'Std deviation of voltage in the three spring slow trial %d : %.2f\n', k-9, stdValue);
                voltageCount = currentTable{:, 2};
                rngTest = max(voltageCount) - min(voltageCount);
                fprintf(fid, 'Range of voltage in the three spring slow trial %d : %.2f\n', k-9, rngTest);
                %Find time from base to peak and avg it
        fprintf(fid, '-----------------------------------------------------------\n');

    elseif (12<k) && (k<16)

            fig = figure(k); clf(fig)
            plot(currentTable,"Time_s_","Voltage_V_",'LineWidth',2);
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('Standing Impulsive Calf Raise V vs T, Trial %d', k-12));
            hold on
            plot(paired_ploc,paired_pks,'r.',MarkerSize=30);
            plot(paired_vloc,-paired_vks,'.',MarkerSize=30);
            legend('Measured Voltage','Peak Voltage', 'Base Voltage',Location='northwest');
            hold off
                                    
                meanValue = mean(currentTable{:, 2}); 
                fprintf(fid, 'Mean voltage in the standing impulse trial %d : %.2f\n', k-12, meanValue);
                stdValue = std(currentTable{:, 2},1);
                fprintf(fid, 'Std deviation of voltage in the standing impulse trial %d : %.2f\n', k-12, stdValue);
                voltageCount = currentTable{:, 2};
                rngTest = max(voltageCount) - min(voltageCount);
                fprintf(fid, 'Range of voltage in the standing impulse trial %d : %.2f\n', k-12, rngTest);
                %Find time from base to peak and avg it
        fprintf(fid, '-----------------------------------------------------------\n');

    elseif (15<k) && (k<19)

            fig = figure(k); clf(fig)
            plot(currentTable,"Time_s_","Voltage_V_",'LineWidth',2);
            xlabel('Time (s)');
            ylabel('Voltage');
            title(sprintf('Standing Slow Calf Raise V vs T, Trial %d', k-12));
            hold on
            plot(paired_ploc,paired_pks,'r.',MarkerSize=30);
            plot(paired_vloc,-paired_vks,'.',MarkerSize=30);
            legend('Measured Voltage','Peak Voltage', 'Base Voltage',Location='northwest');
            hold off
                                                
                meanValue = mean(currentTable{:, 2}); 
                fprintf(fid, 'Mean voltage in the standing slow trial %d : %.2f\n', k-15, meanValue);
                stdValue = std(currentTable{:, 2},1);
                fprintf(fid, 'Std deviation of voltage in the standing slow trial %d : %.2f\n', k-15, stdValue);
                voltageCount = currentTable{:, 2};
                rngTest = max(voltageCount) - min(voltageCount);
                fprintf(fid, 'Range of voltage in the standing slow trial %d : %.2f\n', k-15, rngTest);
                %Find time from base to peak and avg it
        fprintf(fid, '-----------------------------------------------------------\n');
    end
    
end

