function [h,hdata] = call_mlphess(mlp,x,t)
%CALL_MLPHESS Evaluate the Hessian matrix for a simple mlp.

hdata = zeros(mlp.ntotalWB);
for v = eye(mlp.ntotalWB);
  hdata(find(v),:) = mlphdotv(mlp,x,t,v);
end

h = hdata;
if isfield(mlp,'beta')
    if ~isempty(mlp.beta)
        % Hessian of Bayesian error function for MLP
        [h,hdata] = hessian_bayes(mlp,hdata);
    end
end


%-------  auxiliary function to calculate Hessian of error function with Bayesian regularisation term ---------------------------------------
function [h,hdata] = hessian_bayes(mlp,hdata) 

%   H - regularised Hessian (evaluated using any zero-mean Gaussian priors on the weights) 
%	HDATA - the data component of the Hessian

h = hdata;

if isfield(mlp,'nwts')
    nwts = mlp.nwts;
elseif isfield(mlp,'ntotalWB')
    nwts = mlp.ntotalWB;
end

if isfield(mlp,'beta')
  h = mlp.beta*h; 
end

if isfield(mlp,'alpha')
  if isscalar(mlp.alpha)
    h = h + mlp.alpha*eye(nwts);
  else
    index = mlp.index;
    h = h + diag(index*mlp.alpha);
  end 
end


%----------------------------------------------------------------------
function hdv = mlphdotv(mlp, x, t, v)
% product of the data Hessian with a vector. 

ndata = size(x, 1);

[y,z] = sim_mlp(mlp,x);		% Standard forward propagation.
zprime = (1-z.*z);			% Hidden unit first derivatives.
zpprime = -2.0*z.*zprime;		% Hidden unit second derivatives.

v_mlp = mlpunpak_weights(mlp,v);

ra1 = x*v_mlp.w1 + ones(ndata, 1)*v_mlp.b1;
rz = zprime.*ra1;
ra2 = rz*mlp.w2 + z*v_mlp.w2 + ones(ndata, 1)*v_mlp.b2;

switch mlp.outfun

  case 'linear'  
    ry = ra2;

  case 'logistic'
    ry = y.*(1 - y).*ra2;

  case 'softmax'    
    nout = size(t, 2);
    ry = y.*ra2 - y.*(sum(y.*ra2, 2)*ones(1, nout));

  otherwise
    error('Unknown activation function');  
end

% Evaluate delta for the output units
delout = y - t;

% Do standard backpropagation
delhid = zprime.*(delout*mlp.w2');


rdelhid = zpprime.*ra1.*(delout*mlp.w2') + zprime.*(delout*v_mlp.w2') + ...
          zprime.*(ry*mlp.w2');

% Evaluate the components of hdv and then merge into long vector
hw1 = x'*rdelhid;
hb1 = sum(rdelhid, 1);
hw2 = z'*ry + rz'*delout;
hb2 = sum(ry, 1);

hdv = [hw1(:)', hb1, hw2(:)', hb2];
