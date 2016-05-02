function [y,z,a] = sim_mlp(mlp, x)
% SIM_MLP	Feedforward simulation of a simple two-layer MLP network
%
% X - input patterns in rows
% Y - corresponding MLP output values in rows 
% Z - activation of each hidden unit
% A - summed input to each output unit

ndata = size(x,1);

z = tanh(x*mlp.w1 + ones(ndata, 1)*mlp.b1);
a = z*mlp.w2 + ones(ndata, 1)*mlp.b2;

switch mlp.outfun

  case 'linear'    
    y = a;

  case 'logistic'  
    y = 1./(1 + exp(-a));

  case 'softmax'   
    y = exp(a)./(sum(exp(a),2)*ones(1,mlp.nout));

  otherwise
    error('ERROR in SIM_MLP: Unknown activation function');  
end

