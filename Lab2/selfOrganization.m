close all;
clear;

plotinit;
data = read('cluster');
units = 5;

vqinit;
singlewinner=1;

%% Competive Learning

% Automatic iteration
% vqiter;

% Step by step
% for i = 1:5
%     waitforbuttonpress;
%     vqstep;
% end

%% Questions

% 1. Single Winner strategy
% Problem: Sometimes an unit is useless and cover nother

% Advantage: For each cluster you have one and only one unit

%% Expectation Maximization
emiterb;

% Step by step
% for i = 1:10
%     var
%     m
%     waitforbuttonpress;
%     emstepb;
% end

%% Questions
% Single winner strategy:
% Only one unit can get a cluster, all the over units stay in the middle
% with a big width

% Move all
% Here all the units are about to cover data, clusters are spliced between more than one units and the width is smaller 
