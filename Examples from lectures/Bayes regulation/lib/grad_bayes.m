
function [g, gdata, gprior] = grad_bayes(mlp,gdata)
%GRAD_BAYES	Evaluate gradient, G, of Bayesian error function for network.
%           It consists of data and prior (regularisation) contributions, GDATA and GPRIOR, respectively 

% Data contribution to the gradient
if isfield(mlp, 'beta')
    g1 = gdata*mlp.beta;
else
    g1 = gdata;
end

% Prior contribution to the gradient.
if isfield(mlp,'alpha')
    w = mlppak_weights(mlp);
    if size(mlp.alpha) == [1 1]
        gprior = w;
        g2 = mlp.alpha*gprior;
    else
        index = mlp.index;

        ngroups = size(mlp.alpha,1);
        gprior = index'.*(ones(ngroups,1)*w);
        g2 = mlp.alpha'*gprior;
    end
else
    gprior = 0;
    g2 = 0;
end

g = g1 + g2;
