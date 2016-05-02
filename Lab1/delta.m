clear;
sepdata;
setdata;

eta = 0.001;
w = randn(1, 3);
X = [patterns; ones(1, ndata)];

for i = 0:20
    % Compute 3 times
    for j = 0:3
        deltaW = -eta*( w*X - targets)*X';
        w = w + deltaW;
    end
    
    % Show
    p = w(1, 1:2);
    k = -w(1, insize+1) / (p*p');
    l = sqrt(p*p');
    axis([-2, 2, -2, 2], 'square');
    plot (patterns(1, find(targets>0)), ...
        patterns(2, find(targets>0)), '*', ...
        patterns(1, find(targets<0)), ...
        patterns(2, find(targets<0)), '+', ...
        [p(1), p(1)]*k + [-p(2), p(2)]/l, ...
        [p(2), p(2)]*k + [p(1), -p(1)]/l, '-');
    drawnow;

    % Wait user
    %waitforbuttonpress;
end