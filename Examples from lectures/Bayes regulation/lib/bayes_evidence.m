function [mlp,gamma,logev] = bayes_evidence(mlp,x,t,num)
% BAYES_EVIDENCE Re-estimate hyperparameters using evidence approximation
% (directly from Netlib)
%
%   NUM - number of iterations of estimation of the hyperparameters, mlp.ALPHA and mlp.BETA
%         (initil values are taken from mlp and the estimates values are put back into mlp) 
%	GAMMA - the number of well-determined parameters 
%   LOGEV - log of the evidence


ndata = size(x, 1);
if nargin == 3
  num = 1;
end

% Extract weights from network
w = mlppak_weights(mlp);

[h,dh] = call_mlphess(mlp,x,t);
clear h;  % To save memory 
if (~isfield(mlp,'beta'))
  local_beta = 1;
end

[evec, evl] = eig(dh);
% set the negative eigenvalues to zero.
evl = evl.*(evl > 0);
% safe_evl is used to avoid taking log of zero
safe_evl = evl + eps.*(evl <= 0);

[e, edata, eprior] = call_mlperr(w, mlp, x, t);

if size(mlp.alpha) == [1 1]
  % Form vector of eigenvalues
  evl = diag(evl);
  safe_evl = diag(safe_evl);
else
  ngroups = size(mlp.alpha, 1);
  gams = zeros(1, ngroups);
  logas = zeros(1, ngroups);
  % Reconstruct data hessian with negative eigenvalues set to zero.
  dh = evec*evl*evec';
end

% Do the re-estimation. 
for k = 1 : num
  % Re-estimate alpha.
  if size(mlp.alpha) == [1 1]
    % Evaluate number of well-determined parameters.
    L = evl;
    if isfield(mlp,'beta')
      L = mlp.beta*L;
    end
    gamma = sum(L./(L + mlp.alpha));
    mlp.alpha = 0.5*gamma/eprior;
    % Partially evaluate log evidence: only include unmasked weights
    logev = 0.5*length(w)*log(mlp.alpha);
  else
    hinv = inv(hbayes(mlp, dh));
    for m = 1 : ngroups
      group_nweights = sum(mlp.index(:, m));
      gams(m) = group_nweights - mlp.alpha(m)*sum(diag(hinv).*mlp.index(:,m));
      mlp.alpha(m) = real(gams(m)/(2*eprior(m)));
      % Weight alphas by number of weights in group
      logas(m) = 0.5*group_nweights*log(mlp.alpha(m));
    end 
    gamma = sum(gams, 2);
    logev = sum(logas);
  end
  % Re-estimate beta.
  if isfield(mlp,'beta')
      mlp.beta = 0.5*(mlp.nout*ndata - gamma)/edata;
      logev = logev + 0.5*ndata*log(mlp.beta) - 0.5*ndata*log(2*pi);
      local_beta = mlp.beta;
  end
  
  % Evaluate new log evidence
  e = error_bayes(mlp,edata);
  if size(mlp.alpha) == [1 1]
    logev = logev - e - 0.5*sum(log(local_beta*safe_evl+mlp.alpha));
  else
    for m = 1:ngroups  
      logev = logev - e - 0.5*sum(log(local_beta*(safe_evl*mlp.index(:, m))+mlp.alpha(m)));
    end
  end
end

