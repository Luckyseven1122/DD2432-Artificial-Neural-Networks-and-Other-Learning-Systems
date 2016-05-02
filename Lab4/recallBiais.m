function [ y ] = recallBiais( w, x )
%RECALL Summary of this function goes here
%   Detailed explanation goes here
biais = sum(x)/length(x);
y = 0.5 + 0.5 * sgn( (x*w' - biais) );

end

