clc;clear;close all;

pict;

w = p1'*p1 + p2'*p2 + p3'*p3;

%figure; vis(p1);

p1n = flipANN(p1,102);
%figure; vis(p1n);
p1nc = recall(w, p1n);
%figure; vis(p1nc);
error = [];
for i = 0:100
    p1n = flipANN(p1,round(1024*i/100));
    p1nc = recall(w, p1n);
    error = [error sum(abs(p1-p1nc))];
end
figure; plot(0:100, error, 'b+-');