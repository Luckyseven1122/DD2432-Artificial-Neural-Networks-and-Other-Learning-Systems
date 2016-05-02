function [ y ] = computeLeastSquares( x, f, units )
    %COMPUTELEASTSQUARES Summary of this function goes here
    %   Detailed explanation goes here
    % Need to precise that var is a variable and not a script
    global var;
    makerbf;
    Phi = calcPhi(x, m, var);
    w = Phi \ f;
    y = Phi*w;
end

