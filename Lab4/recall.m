function [ y ] = recall( w, x )
%RECALL Summary of this function goes here
%   Detailed explanation goes here
y = sgn( (x*w') );

end

