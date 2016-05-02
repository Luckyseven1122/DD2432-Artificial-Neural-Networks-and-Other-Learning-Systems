% A simple example of bayesian regression for the MLP (based on the original implementation of Netlab)
%
%	f(X) = SIN(2*PI*X) 
%
%   - f is an underlying function that we attempt to model 
%   - data points (X,T) are sampled from noisy environment f(X) + noise_std * N(0,1) 
%     (underlying function plus Gaussian noise with the given std dev)
%   - two-layer MLP network with linear outputs is trained by minimizing a sum-of-squares error function 
%     with the scaled conjugate gradient algorithm 
%   - to prevent overfitting a Gaussian regulariser is applied 
%	- the hyperparameters ALPHA and BETA are re-estimated using the function BAYES_EVIDENCE.
%   - for illlustrative purposes, a figure is plotted of the original underlying function,
%     the training data, the trained network function, and the error bars (from Bayesian regularisation, MLP_BAYESEVIDENCE_FWD).


%-----------------------------------------------------------------------
%               DATA SPECIFICATION
%-----------------------------------------------------------------------
% Define the underlying function
myfun = @(x) sin(2*pi*x);

% Generate the input data - (x,t)
ndata = 16;             % number of data points
noise_std = 0.2;		% standard deviation of Gaussian noise distribution

randn('state',0);
%x = 0.25 + 0.1*randn(ndata,1);     % the domain where the measurements are made - they are randomly distributed in the X subdomain
x = [0.25 + 0.08*randn(fix(ndata/2),1); 0.6 + 0.06*randn(fix(ndata/2),1)];

noise_term = noise_std*randn(size(x));
t = myfun(x) + noise_term;          % ndata noisy samples (measurements)

% Plot the data and the original sine function
h = figure; hold on;
set(gca,'FontSize',14);
plot_x = 0:0.01:1; 
plot(plot_x,myfun(plot_x),'-k','LineWidth',2);
plot(x, t, 'ok');
xlabel('Input');
ylabel('Target');
axis([0 1 -1.5 1.5]);

legend('underlying function','available samples');
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
%               INITIALISE NETWORK
%-----------------------------------------------------------------------
% Set up network parameters - 1 input, 3 hidden units, 1 output 
Ninputs = 1;            % number of inputs
Nhidden = 3;            % number of hidden units
Noutputs = 1;           % number of outputs
Alpha_init = 0.01;		% initial prior hyperparameter, alpha 
Beta_init = 50.0;       % initial noise hyperparameter, beta
bias_var_init = 0.1;      % variance of normal initialisation of biases: try between 0 and 1

% Create and initialise the network (weights are randomly picked and depend on alpha)
mlp = init_mlp(Ninputs,Nhidden,Noutputs,'linear',Alpha_init,Beta_init,bias_var_init);
%-----------------------------------------------------------------------
% For comparison, an alternative network is used without Bayes regularisation
mlp_without_bayes = init_mlp(Ninputs,Nhidden,Noutputs,'linear',Alpha_init,[],bias_var_init);
% 1) BIAS_VAR_INIT affects the result for MLP trained without Bayes regularisation
% 2) if BETA_INIT is here an empty set then no Bayes regularisation is used
% 3) if BETA_INIT is not an empty set here then Bayes regularisation without updating hyperparameters is in use

disp('Start training the network and optimise the hyperparameters, alpha and beta.')
disp('Press any key to proceed with training.');
pause;


%-----------------------------------------------------------------------
%               TRAINING THE NETWORK WITH BAYESIAN REGULARISATION 
%-----------------------------------------------------------------------
% Set up vector of options for the optimiser
Nouterloops = 5;			% number of outer loops - conjugate gradient training + hyperparameter re-estimation
Ninnerloops = 1;			% number of iterations of Bayesian re-estimation of hyperparameters
options = zeros(1,18);		% default options vector
options(2) = 1.0e-7;		% absolute precision for weights
options(3) = 1.0e-7;		% precision for objective function
options(14) = 100;          % the number of training iterations (concerns only conjugate training) within one outer loop. 

% Train using scaled conjugate gradients and re-estimate alpha and beta within Bayesian reggularisation framework
mlp_error = []; mlp_error_without_bayes = [];

for k = 1:Nouterloops

  %1a) train with scaled conjugate gradient for number of loops=options(14)(here: 100)
  w = mlppak_weights(mlp);                      % vector representation of all weights and biases
  [w,opt] = trainmlp_scg(w,options,mlp,x,t);    % actual training with scaled conjugate gradient optimisation algorithm
  mlp = mlpunpak_weights(mlp,w);                % mlp struct representation of weights and biases

  %1b) alternative evaluation for the corresponding MLP trained without regularisation
  w_without_bayes = mlppak_weights(mlp_without_bayes);
  w_without_bayes = trainmlp_scg(w_without_bayes,options,mlp_without_bayes,x,t);    
  mlp_without_bayes = mlpunpak_weights(mlp_without_bayes,w_without_bayes); 
    
  %2) estimate alpha and beta in Bayseian regularisation framework 
  [mlp,gamma] = bayes_evidence(mlp,x,t,Ninnerloops);    % gamma corresponds to the number of well-determined parameters (effective weights and biases)
   
  %3a) calculate error on available data
  mlp_output = sim_mlp(mlp,x);
  mlp_error(k) = sum((mlp_output-t).^2)/length(t);
  
  %3b) alternative evaluation for the corresponding MLP trained without regularisation
  mlp_error_without_bayes(k) = sum((sim_mlp(mlp_without_bayes,x)-t).^2)/length(t);
  
  disp('-----------------------------------------');
  disp(sprintf('  \nRe-estimation cycle %d out of %d:',k,Nouterloops));
  disp(sprintf('  alpha =  %7.3f',mlp.alpha));
  disp(sprintf('  beta  =  %7.3f',mlp.beta));
  disp(sprintf('  gamma =  %7.3f\n',gamma));  
    
end

disp('---------   SUMMARY   -----------');
disp(sprintf(' Estimated alpha: %6.3f    ',mlp.alpha));
disp(sprintf(' Estimated beta : %6.3f     True beta : %6.3f',mlp.beta,1/(noise_std*noise_std)));
disp(sprintf(' Estimated gamma: %6.3f    ',gamma));
disp('---------------------------------');

% figure; hold on;
% set(gca,'FontSize',14);
% plot(mlp_error,'*r','MarkerSize',10);
% plot(mlp_error_without_bayes,'og','MarkerSize',10);
% mlp_err_aux = [mlp_error mlp_error_without_bayes];
% ylim([mean(mlp_err_aux)-2*std(mlp_err_aux)   mean(mlp_err_aux)+2*std(mlp_err_aux)]);
% xlabel('Iterations');
% ylabel('MSE');
% legend('with Bayesian regularisation','without Bayesian regularisation');
% set(gca,'FontSize',14);
%--------------------------------------------------------------------------


disp('Evaluate and show error bars.')
disp('Press any key to proceed with error bars.');
pause;


%-----------------------------------------------------------------------
%                               ERORR BARS 
%-----------------------------------------------------------------------
% Calculate the network's output and evaluate error bars from Bayes evidence over the entire function domain (plot_x)
[simmlp_output,sq_errbar] = mlp_bayesevidence_fwd(mlp,x,t,plot_x');  %sq_errbar corresponds to the variance

% Calculate the output for the MLP trained without Bayes regularisation
simmlp_without_bayes_output = sim_mlp(mlp_without_bayes,plot_x');

% Plot the data (measurements), the underlying function, and the trained network function
figure(h); hold on;
plot(plot_x,simmlp_without_bayes_output,'-g','LineWidth',2)
plot(plot_x,simmlp_output,'-r','LineWidth',2)
plot(plot_x,simmlp_output + sqrt(sq_errbar),'--b','LineWidth',1.5);
plot(plot_x,simmlp_output - sqrt(sq_errbar),'--b','LineWidth',1.5);
xlabel('Input')
ylabel('Output')
legend('underlying function','available samples','MLP predictions without Bayes reg','MLP predictions with Bayes reg','error bars');
