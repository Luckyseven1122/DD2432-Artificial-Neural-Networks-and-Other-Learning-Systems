function [ normW ] = keepBorder( w, outputSize )
%KEEPCIRCLE Summary of this function goes here
%   Detailed explanation goes here
if w > outputSize
    normW = outputSize;
elseif w < 1
    normW = 1;
else
    normW = w;
end

end

