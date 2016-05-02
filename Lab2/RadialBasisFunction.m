%% Computing the weight matrix
% 1. What is the lower bound for the number of training examples, N ?
% 1 ?

% 2. What happens with the error N = n ? Why ?
% There is as many examples as number of weight. We can find a perfect,
% each point is memorized in one noe.

% 3. Under what conditions, if any, does have a solution in this case ?

% 4.During training we use an error measure defined over the training
% examples. Is it good to use this measure when evaluating the performance
% of the network ?
% The error is just used to know how to improve the network. In order to
% have an idea of the performance of the network, we should use
% non-training data. 

%% Supervised Learning of Network Weights
N = 10;
x = 0:1/N:2*pi;
x = x';
units = 6;
f = sin(2*x);

% Compute and show
makerbf;
% Compute the x through x
Phi = calcPhi(x, m, var);
% Find the best solution w for retrieving sin(2x)
w = Phi \ f;
% Compute approximation function
y = Phi*w;

rbfplot1(x, y, f, units);
subplot(211), hold on, plot(m, zeros(length(m)), 'og');

% 1. Units require to get down a maximum residual value
% Search for minimizing residual errors
% CODE: try to minimize the residual by changing the number of units %
% r = [1];
% units = 1;
% while r(end) > 0.001
% y = computeLeastSquares(x, f, units);
% r = [ r max(abs(f - y))];
% units = units + 1;
% end
% r = r(1, 2:end); % Remove fake first value
% plot(1:units-1, r, 'b-');
% % ANSWERS %
% Sinus
% 0.1> 7
% 0.01> 25
% 0.001> 56
% Square
% 0.1> 62
% 0.01> 64 (overdetermined)
% 0.001> 64

% 2. The difference between 5 and 6 units is shannon law we need sampling
% with 2 times the frequency

% 3.Approximating square(2x) is similar to the perceptrion treshold
% --> Classification

% 4. To get a residual value around 0, you need an overdetermined system.
% That's happen when #units >= ? > #x

% 5. Solve the XOR Problem 
% --> Impossible because of linearity