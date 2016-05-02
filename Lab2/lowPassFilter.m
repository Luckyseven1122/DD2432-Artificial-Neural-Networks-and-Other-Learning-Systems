function [ xp ] = lowPassFilter( x, low )
%LOWPASSFILTER Summary of this function goes here
%   Detailed explanation goes here
aLow = 1 / (1 + low);
xp(1, :) = x(1, :);
for i = 2:length(x)
    xp(i, :) = x(i,:) * aLow + (1-aLow) * xp(i-1,:);
end

end

