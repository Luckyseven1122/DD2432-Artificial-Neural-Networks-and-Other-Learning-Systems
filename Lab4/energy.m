function [ E] = energy( w, x )
%ENERGY Summary of this function goes here
%   Detailed explanation goes here
E = - sum ( sum( w * (x'*x) ) );

end

