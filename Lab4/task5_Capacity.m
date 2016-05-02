clc;clear;close all;

%% Watch difference between random and structured images
% % pict;
% 
% %  Random patterns
% p1 = sign(randn(1,1024));
% p2 = sign(randn(1,1024));
% p3 = sign(randn(1,1024));
% p4 = sign(randn(1,1024));
% p5 = sign(randn(1,1024));
% p6 = sign(randn(1,1024));
% p7 = sign(randn(1,1024));
% p11 = flip(p1, 800);
% 
% w = p1'*p1 + p2'*p2 + p3'*p3;
% pc11c = recall(w, p11);
% error = sum(abs(p1-pc11c))
% 
% % Just one more
% w1 = w + p4'*p4;
% pc11c = recall(w1, p11);
% error1 = sum(abs(p1-pc11c))
% 
% % Still more
% w2 = w1 + p5'*p5 + p6'*p6 + p7'*p7;;
% pc11c = recall(w2, p11);
% error2 = sum(abs(p1-pc11c))
% 
% % In other order
% w3 = w + p7'*p7 + p5'*p5 + p4'*p4 + p6'*p6;
% pc11c = recall(w3, p11);
% error3 = sum(abs(p1-pc11c))

%% Test maximum capacity of network
% Number of patters
P = 1000;
% Size of image 
N = 100;
% Normal 
p = sign(randn(P,N));
% Biais
% p = sign(0.5+randn(P,N));
s =[];
w = zeros(N, N);
for i = 1:P
    pc = p(i,:);
    w = w + pc'*pc;
    % Transform w gto resist to noise
    w = w-diag(diag(w));
    good = 0;
    for j = 1:i
        pcc = p(j,:);
        result = recall(w, pcc);
        if sum(abs(pcc-result)) == 0
            good = good + 1;
        end
    end
    % Add percentage of good pattern stored
    s = [s good*100/i];
end

plot(0:P-1, s, 'b+-');
