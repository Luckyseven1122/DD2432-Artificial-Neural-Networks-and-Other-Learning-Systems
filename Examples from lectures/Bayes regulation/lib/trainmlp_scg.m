function [x, options] = trainmlp_scg(x,options,varargin)
% TRAINMLP_SCG	Scaled conjugate gradient for a simple mlp (adopted directly from Netlab)

if(options(14))
    niters = options(14);
else
    niters = 100;
end

display = options(1);
%gradcheck = options(9);

nparams = length(x);

sigma0 = 1.0e-4;
fold = call_mlperr(x,varargin{:});
fnow = fold;
options(10) = options(10) + 1;		% Increment function evaluation counter.
gradnew = call_mlpgrad(x,varargin{:});
gradold = gradnew;
options(11) = options(11) + 1;		% Increment gradient evaluation counter.
d = -gradnew;				% Initial search direction.
success = 1;				% Force calculation of directional derivs.
nsuccess = 0;				% nsuccess counts number of successes.
scg_beta = 1.0;				% Initial scale parameter.
scg_betamin = 1.0e-15; 			% Lower bound on scale.
scg_betamax = 1.0e100;			% Upper bound on scale.
j = 1;					% j counts number of iterations.


% Main optimization loop.
while (j <= niters)

    % Calculate first and second directional derivatives.
    if (success == 1)
        mu = d*gradnew';
        if (mu >= 0)
            d = - gradnew;
            mu = d*gradnew';
        end
        kappa = d*d';
        if kappa < eps
            options(8) = fnow;
            return
        end
        sigma = sigma0/sqrt(kappa);
        xplus = x + sigma*d;
        gplus = call_mlpgrad(xplus,varargin{:});
        options(11) = options(11) + 1;
        theta = (d*(gplus' - gradnew'))/sigma;
    end

    % Increase effective curvature and evaluate step size alpha.
    delta = theta + scg_beta*kappa;
    if (delta <= 0)
        delta = scg_beta*kappa;
        scg_beta = scg_beta - theta/kappa;
    end
    alpha = - mu/delta;

    % Calculate the comparison ratio.
    xnew = x + alpha*d;
    fnew = call_mlperr(xnew,varargin{:});
    options(10) = options(10) + 1;
    Delta = 2*(fnew - fold)/(alpha*mu);
    if (Delta  >= 0)
        success = 1;
        nsuccess = nsuccess + 1;
        x = xnew;
        fnow = fnew;
    else
        success = 0;
        fnow = fold;
    end

    
    if display > 0
        fprintf(1, 'Cycle %4d  Error %11.6f  Scale %e\n', j, fnow, scg_beta);
    end

    if (success == 1)
        % Test for termination

        if (max(abs(alpha*d)) < options(2) & max(abs(fnew-fold)) < options(3))
            options(8) = fnew;
            return;

        else
            % Update variables for new position
            fold = fnew;
            gradold = gradnew;
            gradnew = call_mlpgrad(x,varargin{:});
            options(11) = options(11) + 1;
            % If the gradient is zero then we are done.
            if (gradnew*gradnew' == 0)
                options(8) = fnew;
                return;
            end
        end
    end

    % Adjust scg_beta according to comparison ratio.
    if (Delta < 0.25)
        scg_beta = min(4.0*scg_beta, scg_betamax);
    end
    if (Delta > 0.75)
        scg_beta = max(0.5*scg_beta, scg_betamin);
    end

    % Update search direction using Polak-Ribiere formula, or re-start
    % in direction of negative gradient after nparams steps.
    if (nsuccess == nparams)
        d = -gradnew;
        nsuccess = 0;
    else
        if (success == 1)
            gamma = (gradold - gradnew)*gradnew'/(mu);
            d = gamma*d - gradnew;
        end
    end
    j = j + 1;
end

% If we get here, then we haven't terminated in the given number of
% iterations.

options(8) = fold;
if (options(1) >= 0)
    disp('Warning: Maximum number of iterations has been exceeded');
end

