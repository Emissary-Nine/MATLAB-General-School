clear; clc;

%% =========================
% INPUTS (EDIT THESE)
%% =========================

Rt = 20;                  % throat radius (mm)
expansion_ratio = 16;     % Ae/At

theta_n = 30;             % deg (start angle)
theta_e = 10;             % deg (exit angle)

theta_n = deg2rad(theta_n);
theta_e = deg2rad(theta_e);

%% =========================
% DERIVED VALUES
%% =========================

Re = Rt * sqrt(expansion_ratio);

% Rao nozzle length (~80% bell)
Ln = 0.8 * ((Re - Rt) / tan(theta_e));

%% =========================
% POINT DEFINITIONS
%% =========================

% Throat (origin)
x_t = 0;
y_t = Rt;

% Point N (start of parabola)
x_n = 0.382 * Rt;
y_n = Rt + 0.382 * Rt;

% Exit
x_e = Ln;
y_e = Re;

%% =========================
% PARABOLA FIT
% y = a x^2 + b x + c
%% =========================

A = [x_n^2, x_n, 1;
     x_e^2, x_e, 1;
     2*x_n, 1,   0];

b_vec = [y_n;
         y_e;
         tan(theta_n)];

coeff = A \ b_vec;

a = coeff(1);
b = coeff(2);
c = coeff(3);

%% =========================
% OUTPUT
%% =========================

fprintf('\n===== NOZZLE GEOMETRY (mm) =====\n');

fprintf('\n--- Radii ---\n');
fprintf('Rt (throat) = %.3f mm\n', Rt);
fprintf('Re (exit)   = %.3f mm\n', Re);

fprintf('\n--- Length ---\n');
fprintf('Ln (nozzle length) = %.3f mm\n', Ln);

fprintf('\n--- Key Points ---\n');
fprintf('Throat: (%.3f, %.3f)\n', x_t, y_t);
fprintf('Point N: (%.3f, %.3f)\n', x_n, y_n);
fprintf('Exit:    (%.3f, %.3f)\n', x_e, y_e);

fprintf('\n--- Equation Driven Curve ---\n');
fprintf('y = %.6f x^2 + %.6f x + %.6f\n', a, b, c);

fprintf('\n--- SolidWorks Inputs ---\n');
fprintf('x start = %.3f mm\n', x_n);
fprintf('x end   = %.3f mm\n', x_e);

fprintf('\n--- Angles ---\n');
fprintf('theta_n = %.2f deg\n', rad2deg(theta_n));
fprintf('theta_e = %.2f deg\n\n', rad2deg(theta_e));