% List of WAV files denoising in a folder
inputFolder = 'D:\VSEA\NOIZEUS\d1'; % Replace with your folder path
outputSuffix = 'd1'; % Suffix for denoised files

% Get list of WAV files in the folder
audioFiles = dir(fullfile(inputFolder, '*.wav'));

% Loop through each WAV file
for i = 1:length(audioFiles)
    % Read the current audio file
    inputFile = fullfile(audioFiles(i).folder, audioFiles(i).name);
    [audioData, fs] = audioread(inputFile);

    % Perform denoising (example using a simple low-pass filter)
    % Customize the denoising process as needed
    denoisedData = lowpass(audioData, 3000, fs); % Example low-pass filter

    % Save the denoised audio, replacing the original file
audiowrite(inputFile, denoisedData, fs);

    % Display progress
    disp(['Denoised and replaced: ', inputFile]);
end

function filteredData = lowpass(data, cutoff, fs)
    % Design a low-pass filter
    nyquist = fs / 2;
    [b, a] = butter(6, cutoff / nyquist, 'low');
    filteredData = filtfilt(b, a, data);
end
