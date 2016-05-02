clc;
clear;
close all;

cities;
epoch = 1600;
eta = 0.8;
[nbrAnimals nbrAttrib] = size(city);
outputSize = 11;
inputSize = 2;
% Random init
% weights = rand(outputSize, inputSize);
% Centroid
centroid = sum(city)/length(city);
weights = ones(outputSize, inputSize) * [centroid(1) 0; 0 centroid(2)];

% tour = [weights; weights(1,:)];
% plot(tour(:,1),tour(: ,2),'b-*',city(:,1),city(:,2),'r+');
% waitforbuttonpress;

% Training
for i = 1:epoch
    % Each animal
    for j = 1:nbrAnimals
        p = city(j, :);
        dist = ones(outputSize, 1)*p - weights;
        DIST = sum(dist.^2, 2);
        [val index] = min(DIST);
        
        % Update 
        % Neighboors between 0-2
        nSize = round((epoch-i)*5/epoch);
        neighboorMin = index - nSize;
        neighboorMax = neighboorMin + 2 * nSize;
        for w = neighboorMin:neighboorMax
            if w > outputSize
                normW = w - outputSize;
            elseif w < 1
                normW = w + outputSize;
            else 
                normW = w;
            end
            distance = p - weights(normW, :);
            weights(normW, :) = weights(normW, :) + eta .* distance;
        end
    end
end

tour = [weights; weights(1,:)];
plot(tour(:,1),tour(: ,2),'b-*',city(:,1),city(:,2),'r+');
        
        