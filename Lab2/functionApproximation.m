clear;
close all;
clc;

% Load data
[xtrain ytrain]=readxy('ballist',2,2);
[xtest ytest]=readxy('balltest',2,2);

%% Low Pass Filter
coef = 0;
xtrain = lowPassFilter(xtrain, coef);
xtest = lowPassFilter(xtest, coef);

% Training
units=20;
data=xtrain;
vqinit;
singlewinner=1;
emiterb;
figure(1), axis([0 1 0 1]);

Phi=calcPhi(xtrain,m,var);

d1=ytrain(:,1);
d2=ytrain(:,2);
dtest1=ytest(:,1);
dtest2=ytest(:,2);

w1=Phi\d1;
w2=Phi\d2;

y1=Phi*w1;
y2=Phi*w2;

Phitest=calcPhi(xtest,m,var);
ytest1=Phitest*w1;
ytest2=Phitest*w2;

figure, train1 = xyplot(d1,y1,'train1')
figure, train2 = xyplot(d2,y2,'train2')
figure, test1 = xyplot(dtest1,ytest1,'test1')
figure, test2 = xyplot(dtest2,ytest2,'test2')

%% Questions
% More you have units:
% Train set is fit better but test set result are almost the same
% Bellow 5 units, there are not enough units to have good result

% Low filter not done
