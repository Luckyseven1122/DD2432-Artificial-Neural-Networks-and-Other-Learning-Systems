function g = call_mlpderiv(mlp,x)
% CALL_MLPDERIV Evaluate derivatives of network outputs with respect to weights.
%
%	MLP - a network data structure 
%   X   - a matrix of input vectors 
%   G   - a three-index matrix whose I, J, K element contains the derivative of network output K with respect to
%         weight or bias parameter J for input pattern I. 
%         (The ordering of the weight and bias parameters is defined by MLPUNPAK_WEIGHTS)


% calculate activation of hidden units
[y,z] = sim_mlp(mlp,x);

ndata = size(x,1);

nwts = mlp.ntotalWB;

g = zeros(ndata, nwts, mlp.nout);
for k = 1 : mlp.nout
  delta = zeros(1,mlp.nout);
  delta(1,k) = 1;
  for n = 1 : ndata
      g(n,:,k) = mlp_backprop_grad(mlp.w2,x(n,:),z(n,:),delta);
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
