function g = call_mlpgrad(w,mlp,x,t)
%CALL_MLPGRAD Evaluate network error gradient

mlp = mlpunpak_weights(mlp,w);

[y,z] = sim_mlp(mlp,x);
delout = y - t;

% bult-in function to calculate backpropagation gradient of error function for two-layer MLP network
gdata = mlp_backprop_grad(mlp.w2,x,z,delout);

g = gdata;
if isfield(mlp,'beta')
    if ~isempty(mlp.beta)
        % overall gradient of Bayesian error function for MLP
        g = grad_bayes(mlp,gdata);
    end
end

%--------   auxiliary function for backropagation of error gradient  ---------
function g = mlp_backprop_grad(w2,x,z,deltas)
%
%   W2 - hidden-to-output-units weights
%	X - input vectors, 
%   Z  - activations of hidden units
%   DELTAS - gradient of the error function with respect to the values of the output units 
%   G - gradient of the error function	with respect to the network weights

% Evaluate second-layer gradients
gw2 = z'*deltas;
gb2 = sum(deltas, 1);

% Do backpropagation
delhid = deltas*w2';
delhid = delhid.*(1.0 - z.*z);

% Evaluate the first-layer gradients
gw1 = x'*delhid;
gb1 = sum(delhid, 1);

g = [gw1(:)', gb1, gw2(:)', gb2];