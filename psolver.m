function p=psolver(D)

[I,J,~]=find(~isnan(D));
S=~isnan(D);
V=D(S==1);
M=sparse((1:size(I,1))',I,ones(size(I)));
N=sparse((1:size(I,1))',J,ones(size(I)));
A=M-N;

p=lsqr(A,V,[],120);