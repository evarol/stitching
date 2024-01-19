function fig=threepanelfig(U)

A=squeeze(max(U,[],3));
B=permute(squeeze(max(U,[],1)),[2 1 3]);
C=permute(squeeze(max(U,[],2)),[2 1 3]);
D=zeros(size(B,1),size(C,1));
fig=[A C';B D];
end