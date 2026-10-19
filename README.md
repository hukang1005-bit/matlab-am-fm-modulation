# AM/FM Modulation and Demodulation in MATLAB

A MATLAB experiment exploring DSB-SC amplitude modulation and frequency modulation using the Handel audio sample.

## Experiments

- DSB-SC AM modulation and the effect of upsampling
- Coherent AM detection with carrier frequency and phase errors
- FM modulation, effective bandwidth, and demodulation
- Receiver bandpass filtering
- AM and FM performance in additive white Gaussian noise (AWGN)

`Code_2360736.m` contains sections (a)–(j), with spectrum plots, recovered waveforms, bandwidth estimates, and SNR measurements.

## Requirements

- MATLAB with Signal Processing Toolbox for `resample`, `fir1`, and `xcorr`
- The MATLAB Handel sample (`load handel`)

## Files

- `Code_2360736.m`: main experiment script
- `design_fir_filter.m`: lowpass and bandpass FIR filter design
- `get_aligned_snr.m`: signal alignment and SNR calculation

## Run

Set the repository folder as the current folder in MATLAB and run:

```matlab
Code_2360736
```

The script produces figures and console output. Audio playback examples are commented out.

## Status

The MATLAB files are preserved unchanged. Execution has not been verified in MATLAB.
