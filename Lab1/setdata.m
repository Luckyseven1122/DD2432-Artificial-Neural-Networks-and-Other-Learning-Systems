% Put all the points together and plot them
patterns = [classA, classB];
targets = [ones(1, 100), -ones(1, 100)];

permute = randperm(200);
% Permute data
patterns = patterns(:, permute);
targets = targets(:, permute);

[insize, ndata] = size(patterns);
[outsize, ndata] = size(targets);

plot (patterns(1, find(targets>0)), ...
patterns(2, find(targets>0)), '*', ...
patterns(1, find(targets<0)), ...
patterns(2, find(targets<0)), '+');
