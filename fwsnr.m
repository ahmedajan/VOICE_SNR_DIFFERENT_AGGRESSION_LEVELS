% fwsnr_calc.m
% This script computes the Frequency Weighted Signal-to-Noise Ratio (FWSNR) 
% for an audio file. It estimates the noise in each frequency bin using the lowest
% 10% of the power values in that bin and applies an A-weighting function to 
% account for human auditory sensitivity.

% Read audio file (replace 'audio.wav' with your file)
[inputSignal, fs] = audioread('audio.wav');

% If stereo, convert to mono by averaging channels
if size(inputSignal,2) > 1
    inputSignal = mean(inputSignal, 2);
end

% Spectrogram parameters
frameDuration = 0.02;     % 20 ms
overlapDuration = 0.01;   % 10 ms
frameSize = round(frameDuration * fs);
overlapSize = round(overlapDuration * fs);
nfft = 2^nextpow2(frameSize);

% Compute the spectrogram
window = hamming(frameSize);
[S, f, t] = spectrogram(inputSignal, window, overlapSize, nfft, fs);
P = abs(S).^2;  % Power spectrogram (magnitude squared)

% Estimate noise power per frequency bin
% For each frequency bin, sort the power values across time and average the lowest 10%
numFrames = size(P, 2);
percentile = 0.10;
numNoiseFrames = max(round(percentile * numFrames), 1);
noisePower = zeros(length(f), 1);
signalPower = mean(P, 2); % Average power per frequency bin

for k = 1:length(f)
    sortedP = sort(P(k, :));
    noisePower(k) = mean(sortedP(1:numNoiseFrames));
end

% Compute A-weighting for each frequency bin using the standard formula
% A(f) in dB: A(f) = 2.00 + 20*log10( (12194^2 * f^4) / ((f^2+20.6^2)*(f^2+107.7^2)*(f^2+737.9^2)*(f^2+12194^2)) )
A_weight_dB = zeros(size(f));
for k = 1:length(f)
    if f(k) == 0
        % For f = 0 Hz, set the weight to 0 dB (or handle separately)
        A_weight_dB(k) = 0;
    else
        numerator = (12194^2) * (f(k)^4);
        denominator = (f(k)^2 + 20.6^2) * (f(k)^2 + 107.7^2) * (f(k)^2 + 737.9^2) * (f(k)^2 + 12194^2);
        A_weight_dB(k) = 2.00 + 20 * log10(numerator/denominator);
    end
end

% Convert A-weighting from dB to a linear power weight.
% Since the A-weighting is given in dB, the linear weighting factor for power is:
%   weight = 10^(A(f)/10)
W = 10.^(A_weight_dB / 10);

% Compute the weighted signal and noise power across all frequency bins
weightedSignalPower = sum(W .* signalPower);
weightedNoisePower = sum(W .* noisePower);

% Compute the Frequency Weighted SNR in dB
FWSNR = 10 * log10(weightedSignalPower / weightedNoisePower);

% Display the result
fprintf('Frequency Weighted SNR (FWSNR): %.2f dB\n', FWSNR);
