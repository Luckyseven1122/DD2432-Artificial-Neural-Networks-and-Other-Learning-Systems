clear;
close all;
clc;

% Load data
[xtrain ytrain]=readxy('ballist',2,2);
figure; scatter3(xtrain(:, 1), xtrain(:, 2), ytrain(:, 1), 'ro')
title('Without low pass');

%% Low Pass Filter
coef = 1000;
xtrain = lowPassFilter(xtrain, coef);
figure; scatter3(xtrain(:, 1), xtrain(:, 2), ytrain(:, 1), 'ro')
title('With low pass');