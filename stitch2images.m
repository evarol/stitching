function [C,cor]=stitch2images(A,B)
% C is the stitched image
% cor is the maximum correlation achieved


% Find the x and y translation of B onto A
A=double(A);
A=padarray(A,[max(size(B,1)-size(A,1),0),max(size(B,2)-size(A,2),0)],0,'post');
B=double(B);
corr = normxcorr2(B, A);
[cor, maxIndex] = max(abs(corr(:)));
[yPeak, xPeak] = ind2sub(size(corr), maxIndex);
corrOffset = [(xPeak-size(B,2)) (yPeak-size(B,1))];

% Translate B and keep the full view
[translatedB,RB] = imtranslate(B, corrOffset, 'FillValues', nan, 'OutputView', 'full');

% Fuse A and B
RA = imref2d(size(A));
C=imfuse(A,RA,translatedB,RB);


% Grab the channels from the fused channels and histogram match them
CB=double(C(:,:,1));
CA=double(C(:,:,2));
CB(CB==0)=nan;
CA(CA==0)=nan;
CA=linhistmatch(CA,CB,100,'non-negative');

%Generate single composite image by averaging these two
C = nanmean(cat(3, CA, CB), 3);
C(isnan(C))=0; % make sure there are no nans
end
