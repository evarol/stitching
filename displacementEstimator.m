function [best_shift,cor]=displacementEstimator(A,B)

% FFT of both volumes
tic;
disp('Calculating FFTs...');
fftA = fftn(A);
fftB = fftn(B);
fftToc=toc;
disp(['FFTs done. Time elapsed(s): ' num2str(fftToc)]);
% % Phase correlation
% cross_power_spectrum = (fftA .* conj(fftB)) ./ abs(fftA .* conj(fftB));
% inverse_fft = ifftn(cross_power_spectrum);
% 
% % Find peak
% [max_val, max_idx] = max(inverse_fft(:));cor=max_val;
% [z_peak, y_peak, x_peak] = ind2sub(size(inverse_fft), max_idx);
% translation = [z_peak, y_peak, x_peak] - size(B);
tic;
disp('Calculating phase correlation...');
output = dftregistration_min_max_3d(fftA,fftB,1);
phaseToc=toc;
disp(['Phase correlation done. Time elapsed(s): ' num2str(phaseToc)]);
clear fftA fftB


translation=output([4 3 5]);
% M=reshape(dec2bin(0:7) - '0', 8, 3);
% possible_translations=translation.*(2*M-1) + (1-M)*size(B);

shifts= translation' + size(B)'*[0 -1 1];

% Enumerate all combinations
possible_translations= combvec(shifts(1,:), shifts(2,:), shifts(3,:))';
possible_translations=possible_translations(all(abs(possible_translations)>=size(B)==0,2),:);
globalTic=tic;
for d=1:size(possible_translations,1)
    translatedB = imtranslate(double(B), possible_translations(d,:), 'FillValues', nan, 'OutputView', 'same');
    pad_size=max(size(translatedB),size(A));
    A_padded_to_translated_B=padarray(double(A),pad_size-size(A),nan,'post');
    try
        cor(d,1)=nancorr(translatedB(:),A_padded_to_translated_B(:));
    catch
        cor(d,1)=nan; %#ok<*AGROW>
    end
    T=toc(globalTic);
    disp(['Enumerating all ' num2str(size(possible_translations,1)) ' possible shifts. Time elapsed(s): ' num2str(T) ' Time left(s): ' num2str((size(possible_translations,1)-d)*(T/d))]);
end
[cor,idx]=nanmax(cor);
best_shift=possible_translations(idx,:);