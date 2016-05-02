function [e,edata,eprior] = mlp_err(mlp,x,t)

%MLPERR	Evaluate error function, E, for two-layer network - it consists of EDATA and EPRIOR contributions

[y,z,a] = sim_mlp(mlp,x);

switch mlp.outfun

  case 'linear'        % Linear outputs
    edata = 0.5*sum(sum((y - t).^2));

  case 'logistic'      
    y = 1./(1 + exp(-a));
    edata = - sum(sum(t.*log(y) + (1 - t).*log(1 - y)));

  case 'softmax'       % Softmax outputs
    nout = size(a,2);
    y = exp(a)./(sum(exp(a), 2)*ones(1,nout));
    % Ensure that log(y) is computable
    y(y<1e-6) = 1e-6;
    edata = - sum(sum(t.*log(y)));

  otherwise
    error('Unknown activation function');  
end

eprior = [];
e = edata;
if isfield(mlp,'beta')
    if ~isempty(mlp.beta)
        % calculate error taking into account Bayesian regularisation term
        [e,edata,eprior] = error_bayes(mlp,edata);
    end
end

