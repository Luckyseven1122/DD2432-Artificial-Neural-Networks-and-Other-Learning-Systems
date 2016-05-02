function y=flipANN(x,n)
y=x;
[dummy,index]=sort(rand(1,size(x,2)));
y(index(1:n))=-y(index(1:n));