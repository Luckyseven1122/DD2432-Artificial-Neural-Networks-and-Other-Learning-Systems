
function [e, edata, eprior] = error_bayes(mlp,edata)
%ERROR_BAYES Evaluate Bayesian error function for mlp

%	[E, EDATA, EPRIOR] = ERROR_BAYES(NET, X, T) returns the data and 
%   prior (regularisation) components of the error, EDATA and EPRIOR, respectively

e1 = edata;
eprior = 0;
e2 = 0;

% Data contribution to the error
if isfield(mlp,'beta')
  e1 = mlp.beta*e1; 
end

% Prior contribution to the error
if isfield(mlp,'alpha')
    w = mlppak_weights(mlp);
    eprior = 0.5*(w*w');
    e2 = eprior*mlp.alpha;
end

e = e1 + e2;
