function [ normW ] = keepCyclic( w, outputSize )
%KEEPCIRCLE Summary of this function goes here
%   Detailed explanation goes here
if w > outputSize
    normW = w - outputSize;
elseif w < 1
    normW = w + outputSize;
else
    normW = w;
end

end

