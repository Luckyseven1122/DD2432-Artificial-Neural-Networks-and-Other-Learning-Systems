clc;clear;close all;

pict;

%% Error test
% w = p1'*p1 + p2'*p2 + p3'*p3;
% figure; vis(p1);
% 
% figure; vis(p11);
% p11c = recall(w, p11);
% figure; vis(p11c);
% sum(abs(p1-p11c))
% 
% figure; vis(p22);
% p22c = recall(w, p22);
% figure; vis(p22c);

%% Sequential learn with randomly units
w = sign(randn(1024));
%w = 0.5*(w+w');
% Number of units selected
N = 200;
temp = p1'*p1 + p2'*p2 + p3'*p3;
E = [];
for i = 0:100000
    index = round(1023* rand(2,N) + 1 );
    for j = 1:10
        w(index(1), index(2)) = temp(index(1), index(2));
    end
    if mod(i, 1000) == 0
        w = 0.5*(w+w');
        E = [E energy(w, p1)];
%       close all;
        figure(1); vis(recall(w, p1));
        figure(2); plot(0:length(E)-1, E, 'r-');
        waitforbuttonpress;
    end
end

    
