% List of WAV files denoising in a folder
inputFolder = 'D:\VSEA\NOIZEUS\d2'; % Replace with your folder path

% Get list of WAV files in the folder
audioFiles = dir(fullfile(inputFolder, '*.wav'));

% Loop through each WAV file
for i = 1:length(audioFiles)
    % Read the current audio file
    inputFile = fullfile(audioFiles(i).folder, audioFiles(i).name);
    [audioData, fs] = audioread(inputFile);

    % Perform aggressive denoising
    % Step 1: Apply a high-order low-pass filter
    denoisedData = lowpass(audioData, 2500, fs); % More aggressive low-pass filter

    % Step 2: Apply a spectral subtraction method (simple noise reduction)
    noiseProfile = mean(denoisedData(1:floor(end*0.1))); % Estimate noise from the first 10% of audio
    denoisedData = denoisedData - noiseProfile; % Subtract noise profile
    denoisedData = max(min(denoisedData, 1), -1); % Clip to ensure values are in range [-1, 1]

    % Save the denoised audio, replacing the original file
    audiowrite(inputFile, denoisedData, fs);

    % Display progress
    disp(['Denoised and replaced: ', inputFile]);
end

function filteredData = lowpass(data, cutoff, fs)
    % Design a low-pass filter
    nyquist = fs / 2;
    [b, a] = butter(8, cutoff / nyquist, 'low'); % Higher order for sharper cutoff
    filteredData = filtfilt(b, a, data);
end