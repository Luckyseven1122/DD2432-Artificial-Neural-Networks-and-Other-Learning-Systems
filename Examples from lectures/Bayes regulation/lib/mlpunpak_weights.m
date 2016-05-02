function net = mlpunpak_weights(net, w)

if net.ntotalWB ~= length(w)
  error('Invalid weight vector length')
end

nin = net.nin;
nhidden = net.nhidden;
nout = net.nout;

mark1 = nin*nhidden;
net.w1 = reshape(w(1:mark1), nin, nhidden);
mark2 = mark1 + nhidden;
net.b1 = reshape(w(mark1 + 1: mark2), 1, nhidden);
mark3 = mark2 + nhidden*nout;
net.w2 = reshape(w(mark2 + 1: mark3), nhidden, nout);
mark4 = mark3 + nout;
net.b2 = reshape(w(mark3 + 1: mark4), 1, nout);
