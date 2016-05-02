function mlp = init_mlp(ninp,nhidden,nout,act_outfunc,alpha,beta,bias_var)
 
% INIT_MLP -	Initialise a simple two-layer MLP network
%	  mlp.nin -> number of input units
%	  mlp.nhidden -> number of units in the hidden layer
%	  mlp.nout  -> number of output units
%	  mlp.totalWB -> total number of weights and biases
%	  mlp.actfun =  'linear' or 'logistic or 'softmax' (act_outfunc)
%     mlp.alpha -> initial value of ALPHA for Bayes regularisation (proportional to std dev of random Gussian weight initialisation)
%     mlp.beta -> initial value of BETA for Bayes regularisation (can be skipped)

mlp.nin = ninp;
mlp.nhidden = nhidden;
mlp.nout = nout;
mlp.ntotalWB = nhidden*(ninp+1)+nout*(nhidden+1);
mlp.outfun = act_outfunc;

if nargin > 4
  mlp.alpha = alpha;   
else
  mlp.alpha = sqrt(mlp.nin) / 100;
end
if nargin > 5
  mlp.beta = beta;
end
if nargin < 7
  bias_var = mlp.alpha;
end

if isempty(mlp.beta)
    mlp = rmfield(mlp,'beta');
end

% normal distribution used for initialisation
mlp.w1 = mlp.alpha*randn(mlp.nin, mlp.nhidden)/sqrt(mlp.nin + 1);
mlp.b1 = bias_var*randn(1, mlp.nhidden)/sqrt(mlp.nin + 1);
mlp.w2 = mlp.alpha*randn(mlp.nhidden, mlp.nout)/sqrt(mlp.nhidden + 1);
mlp.b2 = bias_var*randn(1, mlp.nout)/sqrt(mlp.nhidden + 1);

mlp.type = 'mlp';


