Different Levels of Voice Denoising


Overview

This project provides a suite of MATLAB scripts designed to perform voice denoising at varying levels of aggressiveness. Each script processes a folder of WAV files and applies progressively advanced techniques to reduce noise in audio recordings. Whether you need basic filtering or extreme noise suppression, you'll find a script that meets your requirements.



Project Files

d1.m: Basic Denoising

Uses a simple low-pass filter with a cutoff of 3000 Hz.
Processes all WAV files in a specified folder.
Overwrites the original files with the denoised output.

d2.m: Aggressive Denoising with Spectral Subtraction

Implements a higher-order low-pass filter (cutoff at 2500 Hz) for sharper attenuation.
Estimates a noise profile from the first 10% of the audio.
Subtracts the estimated noise and clips the output to ensure values remain within the acceptable range.

d3.m: Advanced Denoising with Smoothing and Normalization

Applies an even more aggressive low-pass filter (cutoff at 2000 Hz) with a high filter order.
Uses spectral subtraction along with noise floor adjustment.
Incorporates a moving average filter to smooth the signal.
Normalizes the output to prevent clipping.

d4.m: Extremely Aggressive Denoising

Applies a very high-order low-pass filter (order 20) with a low cutoff frequency (1000 Hz) for maximum high-frequency noise removal.
Performs multi-band noise reduction using spectral gating to suppress noise across different frequency bands.
Enhances noise reduction by applying a Wiener filter.
Uses a larger moving average window (20 ms) for additional smoothing.
Normalizes the final output to ensure that the maximum amplitude remains within acceptable limits.


SNR Calculation Scripts

snr.m: Overall SNR Calculation

Estimates the overall Signal-to-Noise Ratio (SNR) of an audio file.
Assumes that low-energy segments (lowest 10% of frames) are dominated by noise and calculates the SNR based on the ratio of signal power to estimated noise power.

ssnr.m: Segmental SNR (SSNR) Calculation

Divides the audio into overlapping frames and computes the per-frame SNR.
Clips the per-frame SNR values to a specified range (e.g., -10 dB to 35 dB) and then averages them to yield the segmental SNR.
Provides a robust metric that better reflects the perceived quality over short segments of audio.

fwsnr.m: Frequency Weighted SNR (FWSNR) Calculation

Computes the spectrogram of the audio to analyze its power distribution across frequency bins.
Estimates noise power for each frequency bin by averaging the lowest 10% of power values.
Applies an A-weighting function to mimic the human ear’s sensitivity across frequencies.
Combines the weighted signal and noise powers to compute the overall Frequency Weighted SNR.
