function [y,errbars,invhess] = mlp_bayesevidence_fwd(mlp,x,t,x_test)
%MLP_BAYESEVIDENCE_FWD Forward propagation with evidence for a simple MLP
%
%   MLP - network structure
%	X and T - input and target training data 
%   X_TEST - input test data
%	Y - forward propagation of x_test through the network (output) 
%   ERRBARS - error bars (variance) for a regression problem 
%	INVHESS - the inverse of the network Hessian computed on the training data inputs and targets

% forward propagation of x_test
[y,z,a] = sim_mlp(mlp,x_test);

% calculate overall gradient
g = call_mlpderiv(mlp,x_test);

% calculate Hessian ...
hess = call_mlphess(mlp,x,t);
% .. or rather its inverse
invhess = inv(hess);

ntest = size(x_test, 1);
var = zeros(ntest, 1);
for idx = 1:1:mlp.nout,
  for n = 1:1:ntest,
    grad = squeeze(g(n,:,idx));
    var(n,idx) = grad*invhess*grad';  
  end
end

switch mlp.outfun
    case 'linear'
        % errbars is variance
        errbars = ones(size(var))./mlp.beta + var;
    case 'logistic'
        % errbars is moderated output
        kappa = 1./(sqrt(ones(size(var)) + (pi.*var)./8));
        errbars = 1./(1 + exp(-kappa.*a));
    case 'softmax'
        % Use extended Mackay formula; beware that this may not be very accurate
        kappa = 1./(sqrt(ones(size(var)) + (pi.*var)./8));
        temp = exp(kappa.*a);
        errbars = temp./(sum(temp, 2)*ones(1, mlp.nout));
    otherwise
        error('Unknown activation function');
end
