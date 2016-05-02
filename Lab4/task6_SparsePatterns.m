clc;clear;close all;

N = 100;
P = 200;
biais = 0.4;
% Create P patterns with a biais 
patterns = round(rand(P, N)-biais);
% Get the average biais
p = sum(sum(patterns))/(N*P);

s =[];
w = zeros(N, N);
for i = 1:P
    pc = patterns(i,:)-p;
    w =  w + (pc)'*(pc);
    % Transform w gto resist to noise
    %w = w-diag(diag(w));
    good = 0;
    for j = 1:i
        pcc = patterns(j,:);
        result = recallBiais(w, pcc);
        if sum(abs(pcc-result)) == 0
            good = good + 1;
        end
    end
    % Add percentage of good pattern stored
    s = [s good*100/i];
end

plot(0:P-1, s, 'b+-');