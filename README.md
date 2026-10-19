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

- MATLAB with Signal Processing Toolbox for `resample`
- The MATLAB Handel sample (`load handel`)
- Two external helper functions: `design_fir_filter` and `get_aligned_snr`

The helper functions are referenced by the script but are not included in this repository. Add their directory to the MATLAB path before running. The script also adds its parent directory to the path with `addpath('..')`.

## Run

Open the repository folder in MATLAB, make the helper functions available, and run:

```matlab
Code_2360736
```

The script produces figures and console output. Audio playback examples are commented out.

## Status

The original MATLAB script is preserved unchanged. Execution has not been verified in MATLAB; a complete run requires the external helper functions above.
