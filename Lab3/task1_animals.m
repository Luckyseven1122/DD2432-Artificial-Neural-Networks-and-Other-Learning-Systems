clc;
clear;
close all;

animals;
epoch = 20;
eta = 0.2;
[nbrAnimals nbrAttrib] = size(props); 
outputSize = 100;
weights = rand(outputSize, 84);

% Training
for i = 1:epoch
    % Each animal
    for j = 1:nbrAnimals
        p = props(j, :);
        dist = ones(outputSize, 1)*p - weights;
        DIST = sum(dist.^2, 2);
        [val index] = min(DIST);
        
        % Update
        nSize = (epoch+1-i)*2;
        neighboorMin = index - nSize;
        if neighboorMin < 1
            neighboorMin = 1;
        end
        neighboorMax = neighboorMin + 2 * nSize;
        if neighboorMax > outputSize
            neighboorMax = outputSize;
        end
        for w = neighboorMin:neighboorMax
            distance = p - weights(w, :);
            weights(w, :) = weights(w, :) + eta * distance;
        end
    end
end

% Result
pos = zeros(32, 1);
for j = 1:nbrAnimals
        p = props(j, :);
        dist = weights - ones(outputSize, 1)*p;
        dist = sum(dist.^2, 2);
        [val index] = min(dist);
        
        pos(j) = index;
end

[dummy, order] = sort(pos);
snames(order)'
        
        