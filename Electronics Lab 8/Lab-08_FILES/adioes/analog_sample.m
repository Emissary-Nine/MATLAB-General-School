close all; clear all; clc;
% This script has been updated 3/7/2016 to use the 12 bit Due instead of
% the 10 bit UNO
% provides continuous A/D conversion and displays
% voltage graphically on screen (0-3.3VDC)

% Press CTRL-C to stop program

% Close all open serial ports
old_s = instrfind;
if (~isempty(old_s))
    fclose(old_s);
    delete(old_s);
end
clear all;
close all;

% Sample rate
fs = 10; % [Hz]
ts = 1/fs; % [sec]

% Number of samples
ns = 1000;

% Open communications with the Arduino
a = arduino('COM3'); % change to your Arduino's COM port

% Specify the pin number to read from (A0 to A5)
inPin = 0;

% Verify user wants to continue
fprintf(1,'%s\n','Press any key to continue.');
pause;

% Check input
testval = a.analogRead(inPin);
if testval < 0 || testval > 4095
    fprintf(1,'%s\n','Invalid reading from Arduino. Verify connections.');
    exit(0);
end

% Initialize variables
t = NaN(ns,1);
y = NaN(ns,1);

% Open a figure for plotting
h = figure;
hold off;
bh = uicontrol('style','push','callback',...
    'set(gcbo,''userdata'',1,''string'',''Finished'')','userdata',0);
set(bh,'string','Stop');

% Get the current time
t0 = clock;

% Sample and plot the AD conversions
tic;

for i=1:ns
    % Get the data from the Arduino
    val = a.analogRead(inPin);
    
    % Store the raw analog to digital number, 12-bit (0->4095)
    t(i) = etime(clock,t0);
    y(i) = val;
    
    % Plot the data
    figure(h);
    plot(t,y,'*-');
    set(gca,'YLim',[0 4095]);
    
    % Check button status
    if get(bh,'userdata')
        break;
    end
    
    % It took some time to perform the computations
    te = toc;
    
    % Delay by the frequency sampling time minus the time to do the loop
    pause(max(0,ts-te));
    
    % Begin computing the time for the loop
    tic;
end

% Truncate if required
if get(bh,'userdata')
    t(i+1:end) = [];
    y(i+1:end) = [];
    ns = length(y);
end

% Save the data acquired from the A/D
save('arduinoAD.mat','t','y');

% Finalize plotting
figure(h);
grid on;
xlabel('Time [sec]');
ylabel('Raw A/D Value');
title('Arduino Due 12-bit A/D Conversion');

% FFT
fs_avg = 1/mean(diff(t));
h3 = figure;
NFFT = 2^nextpow2(ns);
Y = fft(y,NFFT);
f = fs_avg/2*linspace(0,1,NFFT/2+1);
plot(f,2*abs(Y(1:NFFT/2+1)));
grid on;
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

% Remove the connection handle
a.delete();

%% Effective Sampling Frequency

dt = diff(t);
dt_avg = mean(dt);

fs_avg = 1/dt_avg;

fprintf('Effective Sampling Frequency = %.2f Hz\n', fs_avg);