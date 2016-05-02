N = 10;
%% Sinux
% x = 0:1/N:2*pi;
% fun = 'sin2x';
%% Exp
x = 0:1/N:4;
fun = 'exp';

x = x';
units = 20;
eta = 0.75;

makerbf;
itermax = 600000;
iter = itermax;
itersub = itermax/100;
diter;

max(abs(f - y))

%% Questions

% 1. Reach \eta = 0.01
% 1st: U=50 / E=0.75 / I=40000
% U=60 better
% I=60000 better and more stable
% By increasing more than I=10^5; I can reach U=40

% 2. Try other functions
% Work well on simple function: linear, cos, sin
% More difficulties when multiple oscillation with sin2x, sin4x...
% Very difficult to get something with exponential
