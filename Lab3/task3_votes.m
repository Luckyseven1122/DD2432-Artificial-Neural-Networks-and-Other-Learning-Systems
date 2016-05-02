clc;
clear;
close all;

Size = 100;
sSize = sqrt(Size);

[x, y] = meshgrid([1:sSize], [1:sSize]);
xpos = reshape(x, 1, Size);
ypos = reshape(y, 1, Size);

createVotes;
epoch = 40;
eta = 0.2;
[nbrAnimals nbrAttrib] = size(votes);
outputSize = Size;
inputSize = nbrAttrib;
weights = rand(outputSize, inputSize);

% Training
for i = 1:epoch
    % Each animal
    for j = 1:nbrAnimals
        p = votes(j, :);
        dist = ones(outputSize, 1)*p - weights;
        DIST = sum(dist.^2, 2);
        [val index] = min(DIST);
        
        % Update 
        % Neighboors between 0-2
        nSize = round((epoch-i)*2/epoch);
        xWinner = xpos(index);
        yWinner = ypos(index);
        for wx = xWinner-nSize:xWinner+nSize
            normWx = keepBorder(wx, sSize);
            for wy = yWinner-nSize:yWinner+nSize
                normWy = keepBorder(wy, sSize);
                normW = (normWx-1)*sSize + normWy;
                distance = p - weights(normW, :);
                weights(normW, :) = weights(normW, :) + eta .* distance;
            end
        end
    end
end


% Result
createMpparty;
pos = zeros(349, 1);
party = zeros(Size, 8);
for j = 1:nbrAnimals
        p = votes(j, :);
        dist = weights - ones(outputSize, 1)*p;
        dist = sum(dist.^2, 2);
        [val index] = min(dist);
        
        pos(j) = index;
        party(index, mpparty(j)+1) = party(index, mpparty(j)+1) + 1;
end

a = ones(1, Size)*350;
a(pos) = 1:349;

% Select the party with maximum of voters for each case
b = zeros(1, Size);
for i = 1:Size
    [vmax posMax] = max(party(i, :));
    if vmax > 0
        b(i) = posMax;
    end
end

% Display
figure(1);
p = [mpparty;0];
image(p(reshape(a,sSize,sSize))+1);

figure(2);
createMpdistrict;
d = [mpdistrict;0];
image(d(reshape(a,sSize,sSize))+1);

figure(3);
createMpsex;
s = [mpsex;0];
image(s(reshape(a,sSize,sSize))+1);
        