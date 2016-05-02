clc;
close all;
clear;

x1=vm([0 0 1 0 1 0 0 1]);
x2=vm([0 0 0 0 0 1 0 0]);
x3=vm([0 1 1 0 0 1 0 1]);
N = log(64);

% w = x1'*x1 + x2'*x2 + x3'*x3;
w = sign(rand(8, 8)*2 - 1);
%% Learn
for i = 0:N
    x1p = recall(w, x1);
    x2p = recall(w, x2);
    x3p = recall(w, x3);
    w = x1p'*x1 + x2p'*x2 + x3p'*x3;
end
%w = w - diag(diag(w));

%% Recall
x_test1 = vm([0 0 1 0 1 0 0 1]);
x_test2 = vm([0 0 1 0 1 0 1 1]);
x_test3 = vm([0 0 1 0 0 1 0 0]);
x_test4 = vm([0 1 1 0 0 1 0 0]);

x1d=vm([1 0 1 0 1 0 0 1]);
x2d=vm([1 1 0 0 0 1 0 0]);
x3d=vm([1 1 1 0 1 1 0 1]);

% Use recall(w, x)
% Change variable to t0

%% Compute attractors

index = de2bi(0:255, 8, 'left-msb');
rIndex = recall(w, vm(index));
rIndex = bi2de(t0(rIndex), 'left-msb');
attractors = length(unique(rIndex));
