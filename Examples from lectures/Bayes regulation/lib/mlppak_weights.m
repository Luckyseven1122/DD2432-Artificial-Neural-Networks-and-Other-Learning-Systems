function w = mlppak_weights(mlp)

w = [mlp.w1(:)', mlp.b1, mlp.w2(:)', mlp.b2];