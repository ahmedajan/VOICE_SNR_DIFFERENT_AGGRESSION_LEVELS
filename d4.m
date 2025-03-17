% List of WAV files denoising in a folder
inputFolder = 'D:\VSEA\NOIZEUS\d4'; % Replace with your folder path

% Get list of WAV files in the folder
audioFiles = dir(fullfile(inputFolder, '*.wav'));

% Loop through each WAV file
for i = 1:length(audioFiles)
    % Read the current audio file
    inputFile = fullfile(audioFiles(i).folder, audioFiles(i).name);
    [audioData, fs] = audioread(inputFile);

    % Perform extremely aggressive denoising
    % Step 1: Apply a very high-order low-pass filter with a very low cutoff frequency
    denoisedData = lowpass(audioData, 1000, fs); % Extremely aggressive low-pass filter

    % Step 2: Perform multi-band noise reduction using spectral gating
    denoisedData = spectralGate(denoisedData, fs); % Apply spectral gating

    % Step 3: Apply Wiener filtering for additional noise suppression
    denoisedData = wienerFilter(denoisedData, fs); % Apply Wiener filter

    % Step 4: Smooth the signal with a larger moving average window
    windowSize = round(0.02 * fs); % 20ms window
    smoothedData = movmean(denoisedData, windowSize);

    % Step 5: Normalize the audio to ensure maximum amplitude is within limits
    smoothedData = smoothedData / max(abs(smoothedData));

    % Save the denoised audio, replacing the original file
    audiowrite(inputFile, smoothedData, fs);

    % Display progress
    disp(['Denoised and replaced: ', inputFile]);
end

function filteredData = lowpass(data, cutoff, fs)
    % Design a low-pass filter
    nyquist = fs / 2;
    [b, a] = butter(20, cutoff / nyquist, 'low'); % Very high order for sharper cutoff
    filteredData = filtfilt(b, a, data);
end

function output = spectralGate(input, fs)
    % Example spectral gating function for aggressive noise reduction
    % Divide the signal into frames, apply noise suppression in each frame
    winLength = round(0.025 * fs); % 25ms window
    overlap = round(0.015 * fs); % 15ms overlap
    [stftData, f, t] = stft(input, fs, 'Window', hamming(winLength, 'periodic'), 'OverlapLength', overlap);
    noiseThreshold = mean(abs(stftData(:, 1:10)), 2) * 1.5; % Estimate noise threshold
    stftData(abs(stftData) < noiseThreshold) = 0; % Suppress noise
    output = istft(stftData, fs, 'Window', hamming(winLength, 'periodic'), 'OverlapLength', overlap);
end

function output = wienerFilter(input, fs)
    % Example Wiener filter implementation
    noiseEstimate = mean(input(1:floor(end*0.1))); % Estimate noise from the first 10% of signal
    inputPower = var(input);
    noisePower = var(noiseEstimate);
    gain = max((inputPower - noisePower) / inputPower, 0.01); % Wiener gain
    output = input * gain;
end
