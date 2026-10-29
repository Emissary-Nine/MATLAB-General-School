clear; close all; clc; 

%% Electronics A/D D/A converter stuff

% v_in = 3.3;
v_max = 3.3;
v_min = 0;
% bits = 8;

% [bin, decimal] = voltage2bin(v_in,v_min,v_max,bits);

%% Sine wave input

offset = 1.65; % VDC
v_pkpk = 3.3; % Vpp
t = 0:0.0001:1; % Define time vector (0 to 1 second with 0.001 step)
f = 1; % Hz

v_in = offset + (v_pkpk/2)*sin(2 * f * pi * t);
bits = 12;

[bin2, decimal2] = voltage2bin(v_in,v_min,v_max,bits);

LocMax = max(decimal2);

% offset (DC) calcs

[binDC, decimalDC] = voltage2bin(offset,v_min,v_max,bits);

%% Minimum sampling frequency

f_max = 4000; % max frequency in Hz
f_smin = 2 * f_max % required sampling

f_s = 4000; % sampling 
f_nyq = f_s / 2 % nyquist frequency

f_alias = abs(f_max - f_s) % aliasing

%% Accelerometer

sens = 0.06;       % V/g
V_M = 3.3;         % Maximum voltage
V_m = 0;           % Minimum voltage

ReqAccelRes = 0.1; % Required resolution in g
ReqRes = sens * ReqAccelRes;  % Required voltage resolution

range = V_M - V_m;
requiredLevels = range / ReqRes;

bitsAccNeed = ceil(log2(requiredLevels));

actualLevels = 2^bitsAccNeed;
actualVoltageRes = range / actualLevels;
actualAccelRes = actualVoltageRes / sens;

fprintf('Required levels: %.0f\n', requiredLevels);
fprintf('Minimum bits: %d\n', bitsAccNeed);
fprintf('Actual acceleration resolution: %.5f g\n', actualAccelRes);