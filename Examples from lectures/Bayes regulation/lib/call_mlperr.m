function [e, varargout] = call_mlperr(w,mlp,x,t)
%wrapper for MLP_ERR

mlp = mlpunpak_weights(mlp,w);

[s{1:nargout}] = mlp_err(mlp,x,t);
e = s{1};
if nargout > 1
  for i = 2:nargout
    varargout{i-1} = s{i};
  end
end
