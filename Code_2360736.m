clear; close all; clc;
addpath('..');

%% Question a) DSB-SC AM modulation

% Load Handel music signal
load handel;                 % y: audio signal, Fs: original sampling frequency
m = y(:);                    % make it a column vector

% Original message bandwidth is roughly limited by Fs/2
Bm = Fs / 2;

% Choose sampling frequency and carrier frequency for AM
Fs_am = 100000;              % sampling frequency after upsampling
fc1 = 25000;                 % carrier frequency for DSB-SC AM

% Resample the message signal
m_am = resample(m, Fs_am, Fs);
t_am = (0:length(m_am)-1)' / Fs_am;

% DSB-SC AM modulation
x_AM = m_am .* cos(2*pi*fc1*t_am);

% Frequency spectrum of DSB-SC AM signal
N = length(x_AM);
f = (-N/2:N/2-1)' * Fs_am / N;
X_AM = fftshift(abs(fft(x_AM))) / N;

figure;
plot(f, X_AM, 'LineWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Spectrum of DSB-SC AM Signal');
grid on;
xlim([-40000 40000]);

%% Question b) Effect of no upsampling

m_no_up = m;                         % original Handel signal without resampling
t_no_up = (0:length(m_no_up)-1)' / Fs;

% Modulation without upsampling
x_AM_no_up = m_no_up .* cos(2*pi*fc1*t_no_up);

% Spectrum with upsampling
N_up = length(x_AM);
f_up = (-N_up/2:N_up/2-1)' * Fs_am / N_up;
X_AM_up = fftshift(abs(fft(x_AM))) / N_up;

% Spectrum without upsampling
N_no = length(x_AM_no_up);
f_no = (-N_no/2:N_no/2-1)' * Fs / N_no;
X_AM_no = fftshift(abs(fft(x_AM_no_up))) / N_no;

% Plot comparison
figure;

subplot(2,1,1);
plot(f_up/1000, X_AM_up, 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('DSB-SC AM Spectrum with Upsampling');
grid on;
xlim([-50 50]);

subplot(2,1,2);
plot(f_no/1000, X_AM_no, 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('DSB-SC AM Spectrum without Upsampling');
grid on;
xlim([-Fs/2 Fs/2]/1000);

%% Question c) Coherent detection for DSB-SC AM

% Lowpass filter bandwidth for recovering the Handel signal
B_lpf_AM = 5000;                 % slightly larger than the message bandwidth

% Coherent multiplication
mixed_AM = 2 * x_AM .* cos(2*pi*fc1*t_am);

% Lowpass filtering
b_lpf_AM = design_fir_filter('lowpass', B_lpf_AM, Fs_am);
m_rec_AM = filter(b_lpf_AM, 1, mixed_AM);

% Normalize the recovered signal power
m_rec_AM = m_rec_AM * sqrt(sum(m_am.^2) / sum(m_rec_AM.^2));

% Use the original signal maximum as the plotting scale
scale_AM = max(abs(m_am));

m_AM_plot = m_am / scale_AM;
m_rec_AM_plot = m_rec_AM / scale_AM;

% Plot the original and recovered signals
figure;

subplot(2,1,1);
plot(t_am, m_AM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

subplot(2,1,2);
plot(t_am, m_rec_AM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered Signal after Coherent Detection');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

% Play the recovered audio if needed
% m_rec_AM_audio = resample(m_rec_AM, Fs, Fs_am);
% soundsc(m_rec_AM_audio, Fs);

%% Question d) Effect of frequency and phase errors in coherent detection

B_lpf_AM = 5000;
b_lpf_AM = design_fir_filter('lowpass', B_lpf_AM, Fs_am);

% Use original signal maximum as the plotting scale
scale_AM = max(abs(m_am));

% Part 1: effect of frequency offset Delta f

delta_f_set = [0 1 2 3];      % frequency offsets in Hz
theta_fixed = 0;              % fixed phase error

m_rec_delta = zeros(length(m_am), length(delta_f_set));

for k = 1:length(delta_f_set)

    delta_f = delta_f_set(k);

    % Receiver carrier with frequency offset
    rx_carrier = cos(2*pi*(fc1 + delta_f)*t_am + theta_fixed);

    % Coherent detection
    mixed_signal = 2 * x_AM .* rx_carrier;

    % Lowpass filtering
    temp_rec = filter(b_lpf_AM, 1, mixed_signal);

    % Store the recovered signal
    m_rec_delta(:,k) = temp_rec;

end

% Plot original signal and recovered signals for different Delta f
figure;

subplot(length(delta_f_set)+1, 1, 1);
plot(t_am, m_am / scale_AM, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

for k = 1:length(delta_f_set)

    subplot(length(delta_f_set)+1, 1, k+1);
    plot(t_am, m_rec_delta(:,k) / scale_AM, 'LineWidth', 1);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['Recovered Signal, \Delta f = ', num2str(delta_f_set(k)), ' Hz']);
    grid on;
    xlim([t_am(1), t_am(end)]);
    ylim([-1 1]);

end


% Part 2: effect of phase error theta

theta_set = [0 0.03 0.06 0.1];     % phase errors in radians
delta_f_fixed = 0;                  % fixed frequency offset

m_rec_theta = zeros(length(m_am), length(theta_set));

for k = 1:length(theta_set)

    theta = theta_set(k);

    % Receiver carrier with phase error
    rx_carrier = cos(2*pi*(fc1 + delta_f_fixed)*t_am + theta);

    % Coherent detection
    mixed_signal = 2 * x_AM .* rx_carrier;

    % Lowpass filtering
    temp_rec = filter(b_lpf_AM, 1, mixed_signal);

    % Store the recovered signal
    m_rec_theta(:,k) = temp_rec;

end

% Plot original signal and recovered signals for different theta
figure;

subplot(length(theta_set)+1, 1, 1);
plot(t_am, m_am / scale_AM, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

for k = 1:length(theta_set)

    subplot(length(theta_set)+1, 1, k+1);
    plot(t_am, m_rec_theta(:,k) / scale_AM, 'LineWidth', 1);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['Recovered Signal, \theta = ', num2str(theta_set(k)), ' rad']);
    grid on;
    xlim([t_am(1), t_am(end)]);
    ylim([-1 1]);

end


% % Play one selected recovered audio
% 
% % Manually change these two values
% delta_f_play = 3;          % choose 0, 1, 2, 3 Hz, or any other value
% theta_play = 0.05;         % choose a value between 0 and 0.1 rad
% 
% % Receiver carrier with selected frequency and phase error
% rx_carrier_play = cos(2*pi*(fc1 + delta_f_play)*t_am + theta_play);
% 
% % Coherent detection
% mixed_play = 2 * x_AM .* rx_carrier_play;
% 
% % Lowpass filtering
% m_rec_play = filter(b_lpf_AM, 1, mixed_play);
% 
% % Normalize power for listening
% m_rec_play = m_rec_play * sqrt(sum(m_am.^2) / sum(m_rec_play.^2));
% 
% % Resample back to the original audio sampling frequency before playback
% m_rec_play_audio = resample(m_rec_play, Fs, Fs_am);
% 
% % Play the selected recovered audio
% soundsc(m_rec_play_audio, Fs);

%% Question e) Frequency modulation

% Use a higher sampling frequency for FM simulation
Fs_fm = 250000;              % sampling frequency for FM
fc2 = 60000;                 % carrier frequency for FM
beta = 20000;                % frequency sensitivity

% Resample the Handel signal for FM
m_fm = resample(m, Fs_fm, Fs);
t_fm = (0:length(m_fm)-1)' / Fs_fm;

% Step 1: test integration and differentiation

% Integrate the message signal
int_m = cumtrapz(t_fm, m_fm);

% Differentiate the integration result
m_diff = [0; diff(int_m) * Fs_fm];

% Plot time-domain comparison
figure;

subplot(2,1,1);
plot(t_fm, m_fm, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_fm(1), t_fm(end)]);

subplot(2,1,2);
plot(t_fm, m_diff, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Signal after Integration and Differentiation');
grid on;
xlim([t_fm(1), t_fm(end)]);


% Spectrum comparison
N_test = length(m_fm);
f_test = (-N_test/2:N_test/2-1)' * Fs_fm / N_test;

M_original = fftshift(abs(fft(m_fm))) / N_test;
M_diff = fftshift(abs(fft(m_diff))) / N_test;

figure;

subplot(2,1,1);
plot(f_test/1000, M_original, 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Spectrum of Original Handel Signal');
grid on;
xlim([-10 10]);

subplot(2,1,2);
plot(f_test/1000, M_diff, 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Spectrum after Integration and Differentiation');
grid on;
xlim([-10 10]);


% Step 2: perform FM modulation

% Generate the FM signal
x_FM = cos(2*pi*fc2*t_fm + 2*pi*beta*int_m);

% Plot FM signal in time domain
figure;

subplot(2,1,1);
plot(t_fm, m_fm, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_fm(1), t_fm(end)]);

subplot(2,1,2);
plot(t_fm, x_FM, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('FM Signal');
grid on;
xlim([0 0.005]);     % show a short interval because FM carrier is high frequency


% Plot FM frequency spectrum
N_fm = length(x_FM);
f_fm = (-N_fm/2:N_fm/2-1)' * Fs_fm / N_fm;
X_FM = fftshift(abs(fft(x_FM))) / N_fm;

figure;
plot(f_fm/1000, X_FM, 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Frequency Spectrum of FM Signal');
grid on;
xlim([-100 100]);

% Play the signal after integration and differentiation
% m_diff_audio = resample(m_diff, Fs, Fs_fm);
% soundsc(m_diff_audio, Fs);

%% Question f) 95% effective bandwidth of FM signal

% Energy density spectrum of FM signal
N_fm = length(x_FM);
f_fm = (-N_fm/2:N_fm/2-1)' * Fs_fm / N_fm;
X_FM = fftshift(fft(x_FM));
E_FM = abs(X_FM).^2;                 % energy density spectrum

% Use the positive-frequency FM band around +fc2
pos_idx = f_fm >= 0;
f_pos = f_fm(pos_idx);
E_pos = E_FM(pos_idx);

% Find the smallest symmetric bandwidth around fc2 that contains 95% energy
freq_offset = abs(f_pos - fc2);
[freq_offset_sorted, sort_idx] = sort(freq_offset);
E_sorted = E_pos(sort_idx);

E_cum = cumsum(E_sorted);
E_total = sum(E_sorted);

idx_95 = find(E_cum >= 0.95 * E_total, 1, 'first');
B_half_95 = freq_offset_sorted(idx_95);
B_95 = 2 * B_half_95;

% Carson's rule
Bm = Fs / 2;                         % approximate message bandwidth
delta_f = beta * max(abs(m_fm));     % peak frequency deviation
B_Carson = 2 * (delta_f + Bm);

% Print results
fprintf('\nQuestion f results:\n');
fprintf('95%% effective bandwidth = %.2f Hz\n', B_95);
fprintf('Carson bandwidth = %.2f Hz\n', B_Carson);
fprintf('Peak frequency deviation = %.2f Hz\n', delta_f);
fprintf('Message bandwidth used in Carson rule = %.2f Hz\n', Bm);

% Plot FM spectrum and mark bandwidths
figure;

plot(f_fm/1000, E_FM / max(E_FM), 'LineWidth', 1);
hold on;

% 95% effective bandwidth boundaries
xline((fc2 - B_half_95)/1000, 'r--', 'LineWidth', 1.2);
xline((fc2 + B_half_95)/1000, 'r--', 'LineWidth', 1.2);
xline((-fc2 - B_half_95)/1000, 'r--', 'LineWidth', 1.2);
xline((-fc2 + B_half_95)/1000, 'r--', 'LineWidth', 1.2);

% Carson's rule boundaries
B_half_Carson = B_Carson / 2;
xline((fc2 - B_half_Carson)/1000, 'k--', 'LineWidth', 1.2);
xline((fc2 + B_half_Carson)/1000, 'k--', 'LineWidth', 1.2);
xline((-fc2 - B_half_Carson)/1000, 'k--', 'LineWidth', 1.2);
xline((-fc2 + B_half_Carson)/1000, 'k--', 'LineWidth', 1.2);

xlabel('Frequency (kHz)');
ylabel('Normalized Energy Density');
title('FM Spectrum with 95% Effective Bandwidth and Carson Bandwidth');
legend('FM spectrum', ...
       '95% bandwidth boundary', '', '', '', ...
       'Carson bandwidth boundary', '', '', '', ...
       'Location', 'best');

grid on;
xlim([-100 100]);
hold off;

%% Question g) FM demodulation

% Parameters for FM demodulator
L = 0.05;                 % hard limiter level
B_lpf_FM = 5000;          % lowpass filter bandwidth for envelope detector

% 1. Hard limiter
x_limited = x_FM;

x_limited(x_limited > L) = L;
x_limited(x_limited < -L) = -L;

% 2. Differentiator
x_diff = [0; diff(x_limited) * Fs_fm];

% 3. Envelope detector: absolute value followed by lowpass filtering
x_abs = abs(x_diff);

b_lpf_FM = design_fir_filter('lowpass', B_lpf_FM, Fs_fm);
env_FM = filter(b_lpf_FM, 1, x_abs);

% 4. Remove DC component
m_rec_FM = env_FM - mean(env_FM);

% 5. Normalize the recovered signal power
m_rec_FM = m_rec_FM * sqrt(sum(m_fm.^2) / sum(m_rec_FM.^2));

% Correct possible sign inversion
if sum(m_fm .* m_rec_FM) < 0
    m_rec_FM = -m_rec_FM;
end

% Use the original signal maximum as the plotting scale
scale_FM = max(abs(m_fm));

m_FM_plot = m_fm / scale_FM;
m_rec_FM_plot = m_rec_FM / scale_FM;

% Plot original and recovered signals
figure;

subplot(2,1,1);
plot(t_fm, m_FM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_fm(1), t_fm(end)]);
ylim([-1 1]);

subplot(2,1,2);
plot(t_fm, m_rec_FM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered Signal after FM Demodulation');
grid on;
xlim([t_fm(1), t_fm(end)]);
ylim([-1 1]);

% Play recovered FM audio if needed
% m_rec_FM_audio = resample(m_rec_FM, Fs, Fs_fm);
% soundsc(m_rec_FM_audio, Fs);

%% Question h) Receiver front bandpass filters for AM and FM

% AM receiver bandpass filter
B_bpf_AM = 10000;                 % bandwidth in Hz
b_bpf_AM = design_fir_filter('bandpass', B_bpf_AM, Fs_am, fc1);

% Apply AM bandpass filter
x_AM_bpf = filter(b_bpf_AM, 1, x_AM);

% Coherent detection after bandpass filtering
B_lpf_AM = 5000;
b_lpf_AM = design_fir_filter('lowpass', B_lpf_AM, Fs_am);

mixed_AM_h = 2 * x_AM_bpf .* cos(2*pi*fc1*t_am);
m_rec_AM_h = filter(b_lpf_AM, 1, mixed_AM_h);

% Power normalization
m_rec_AM_h = m_rec_AM_h * sqrt(sum(m_am.^2) / sum(m_rec_AM_h.^2));

% Use the original signal maximum as the plotting scale
scale_AM = max(abs(m_am));

m_AM_plot = m_am / scale_AM;
m_rec_AM_h_plot = m_rec_AM_h / scale_AM;

% Frequency response of AM bandpass filter
[H_AM, f_H_AM] = freqz(b_bpf_AM, 1, 4096, Fs_am);

figure;
tiledlayout(2,2);

% Left: AM bandpass filter response
nexttile([2 1]);
plot(f_H_AM/1000, abs(H_AM), 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('AM Receiver Bandpass Filter Response');
grid on;
xlim([0 50]);

% Right top: original signal
nexttile;
plot(t_am, m_AM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

% Right bottom: recovered AM signal
nexttile;
plot(t_am, m_rec_AM_h_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered AM Signal after Bandpass Filtering');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

% Play recovered AM audio if needed
% m_rec_AM_h_audio = resample(m_rec_AM_h, Fs, Fs_am);
% soundsc(m_rec_AM_h_audio, Fs);

% FM receiver bandpass filter
B_bpf_FM = 50000;                 % bandwidth in Hz
b_bpf_FM = design_fir_filter('bandpass', B_bpf_FM, Fs_fm, fc2);

% Apply FM bandpass filter
x_FM_bpf = filter(b_bpf_FM, 1, x_FM);

% FM demodulation after bandpass filtering
L = 0.05;
B_lpf_FM = 5000;

% Hard limiter
x_limited_h = x_FM_bpf;
x_limited_h(x_limited_h > L) = L;
x_limited_h(x_limited_h < -L) = -L;

% Differentiator
x_diff_h = [0; diff(x_limited_h) * Fs_fm];

% Envelope detector
x_abs_h = abs(x_diff_h);

b_lpf_FM = design_fir_filter('lowpass', B_lpf_FM, Fs_fm);
env_FM_h = filter(b_lpf_FM, 1, x_abs_h);

% Remove DC component
m_rec_FM_h = env_FM_h - mean(env_FM_h);

% Power normalization
m_rec_FM_h = m_rec_FM_h * sqrt(sum(m_fm.^2) / sum(m_rec_FM_h.^2));

% Correct possible sign inversion
if sum(m_fm .* m_rec_FM_h) < 0
    m_rec_FM_h = -m_rec_FM_h;
end

% Use the original signal maximum as the plotting scale
scale_FM = max(abs(m_fm));

m_FM_plot = m_fm / scale_FM;
m_rec_FM_h_plot = m_rec_FM_h / scale_FM;

% Frequency response of FM bandpass filter
[H_FM, f_H_FM] = freqz(b_bpf_FM, 1, 4096, Fs_fm);

figure;
tiledlayout(2,2);

% Left: FM bandpass filter response
nexttile([2 1]);
plot(f_H_FM/1000, abs(H_FM), 'LineWidth', 1);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('FM Receiver Bandpass Filter Response');
grid on;
xlim([0 125]);

% Right top: original signal
nexttile;
plot(t_fm, m_FM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_fm(1), t_fm(end)]);
ylim([-1 1]);

% Right bottom: recovered FM signal
nexttile;
plot(t_fm, m_rec_FM_h_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered FM Signal after Bandpass Filtering');
grid on;
xlim([t_fm(1), t_fm(end)]);
ylim([-1 1]);

% Play recovered FM audio if needed
% m_rec_FM_h_audio = resample(m_rec_FM_h, Fs, Fs_fm);
% soundsc(m_rec_FM_h_audio, Fs);

%% Question i) DSB-SC AM system with AWGN

% Target SNR at AM bandpass filter output
target_SNR_AM_dB = 10;
target_SNR_AM_linear = 10^(target_SNR_AM_dB/10);

% Use the AM receiver bandpass filter from Question h
B_bpf_AM = 10000;
b_bpf_AM = design_fir_filter('bandpass', B_bpf_AM, Fs_am, fc1);

% Generate standard Gaussian noise
rng(1);                         % for repeatable result
noise_AM_unit = randn(size(x_AM));

% Clean signal and unit-noise after AM bandpass filter
x_AM_bpf_clean = filter(b_bpf_AM, 1, x_AM);
noise_AM_bpf_unit = filter(b_bpf_AM, 1, noise_AM_unit);

% Calculate the noise scaling factor
P_signal_bpf_AM = mean(x_AM_bpf_clean.^2);
P_noise_bpf_unit_AM = mean(noise_AM_bpf_unit.^2);

A_noise_AM = sqrt(P_signal_bpf_AM / ...
                 (target_SNR_AM_linear * P_noise_bpf_unit_AM));

% Add scaled AWGN to the AM signal
noise_AM = A_noise_AM * noise_AM_unit;
r_AM = x_AM + noise_AM;

% Pass the noisy AM signal through the receiver bandpass filter
r_AM_bpf = filter(b_bpf_AM, 1, r_AM);

% Verify the SNR at the AM bandpass filter output
noise_AM_bpf_actual = r_AM_bpf - x_AM_bpf_clean;
SNR_AM_bpf_actual = 10 * log10(mean(x_AM_bpf_clean.^2) / ...
                               mean(noise_AM_bpf_actual.^2));

% Coherent detection for clean and noisy AM signals

B_lpf_AM = 5000;
b_lpf_AM = design_fir_filter('lowpass', B_lpf_AM, Fs_am);

% Clean demodulation output
mixed_AM_clean_i = 2 * x_AM_bpf_clean .* cos(2*pi*fc1*t_am);
m_rec_AM_clean_i = filter(b_lpf_AM, 1, mixed_AM_clean_i);

% Noisy demodulation output
mixed_AM_noisy_i = 2 * r_AM_bpf .* cos(2*pi*fc1*t_am);
m_rec_AM_noisy_i = filter(b_lpf_AM, 1, mixed_AM_noisy_i);

% Use the same normalization factor for clean and noisy outputs
alpha_AM_i = sqrt(sum(m_am.^2) / sum(m_rec_AM_clean_i.^2));

m_rec_AM_clean_i = alpha_AM_i * m_rec_AM_clean_i;
m_rec_AM_noisy_i = alpha_AM_i * m_rec_AM_noisy_i;

% Calculate output SNR using the given function
SNR_AM_output = get_aligned_snr(m_rec_AM_clean_i, m_rec_AM_noisy_i);

% Print results
fprintf('\nQuestion i results:\n');
fprintf('Noise scaling factor A_noise_AM = %.6f\n', A_noise_AM);
fprintf('SNR at AM bandpass filter output = %.2f dB\n', SNR_AM_bpf_actual);
fprintf('SNR at coherent detector output = %.2f dB\n', SNR_AM_output);

% Plot original and noisy recovered AM signal
% Use the original signal maximum as the plotting scale
scale_AM = max(abs(m_am));

m_AM_plot = m_am / scale_AM;
m_rec_AM_noisy_plot = m_rec_AM_noisy_i / scale_AM;

figure;

subplot(2,1,1);
plot(t_am, m_AM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

subplot(2,1,2);
plot(t_am, m_rec_AM_noisy_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered AM Signal with AWGN');
grid on;
xlim([t_am(1), t_am(end)]);
ylim([-1 1]);

% Play recovered noisy AM audio if needed
% m_rec_AM_noisy_audio = resample(m_rec_AM_noisy_i, Fs, Fs_am);
% soundsc(m_rec_AM_noisy_audio, Fs);

%% Question j) FM system with AWGN

% The equivalent noise PSD should be the same as in the AM system.
A_noise_FM = A_noise_AM * sqrt(Fs_fm / Fs_am);

% Generate FM noise
rng(2);                         % for repeatable result
noise_FM_unit = randn(size(x_FM));
noise_FM = A_noise_FM * noise_FM_unit;

% Add AWGN to the FM signal
r_FM = x_FM + noise_FM;

% Check the equivalent PSD values
PSD_noise_AM = A_noise_AM^2 / Fs_am;
PSD_noise_FM = A_noise_FM^2 / Fs_fm;

% Receiver bandpass filter for FM

B_bpf_FM = 50000;                 % FM bandpass filter bandwidth in Hz
b_bpf_FM = design_fir_filter('bandpass', B_bpf_FM, Fs_fm, fc2);

% Clean and noisy FM signals after receiver bandpass filter
x_FM_bpf_clean_j = filter(b_bpf_FM, 1, x_FM);
r_FM_bpf = filter(b_bpf_FM, 1, r_FM);

% Calculate the SNR at the FM bandpass filter output for reference
noise_FM_bpf_actual = r_FM_bpf - x_FM_bpf_clean_j;
SNR_FM_bpf_actual = 10 * log10(mean(x_FM_bpf_clean_j.^2) / ...
                               mean(noise_FM_bpf_actual.^2));

% FM demodulation for clean FM signal

L = 0.05;
B_lpf_FM = 5000;

% Hard limiter
x_limited_clean_j = x_FM_bpf_clean_j;
x_limited_clean_j(x_limited_clean_j > L) = L;
x_limited_clean_j(x_limited_clean_j < -L) = -L;

% Differentiator
x_diff_clean_j = [0; diff(x_limited_clean_j) * Fs_fm];

% Envelope detector
x_abs_clean_j = abs(x_diff_clean_j);

b_lpf_FM = design_fir_filter('lowpass', B_lpf_FM, Fs_fm);
env_FM_clean_j = filter(b_lpf_FM, 1, x_abs_clean_j);

% Remove DC component
m_rec_FM_clean_j = env_FM_clean_j - mean(env_FM_clean_j);

% FM demodulation for noisy FM signal

% Hard limiter
x_limited_noisy_j = r_FM_bpf;
x_limited_noisy_j(x_limited_noisy_j > L) = L;
x_limited_noisy_j(x_limited_noisy_j < -L) = -L;

% Differentiator
x_diff_noisy_j = [0; diff(x_limited_noisy_j) * Fs_fm];

% Envelope detector
x_abs_noisy_j = abs(x_diff_noisy_j);

env_FM_noisy_j = filter(b_lpf_FM, 1, x_abs_noisy_j);

% Remove DC component
m_rec_FM_noisy_j = env_FM_noisy_j - mean(env_FM_noisy_j);

% Normalization and SNR calculation

% Use the clean FM demodulated output to calculate the normalization factor
alpha_FM_j = sqrt(sum(m_fm.^2) / sum(m_rec_FM_clean_j.^2));

m_rec_FM_clean_j = alpha_FM_j * m_rec_FM_clean_j;
m_rec_FM_noisy_j = alpha_FM_j * m_rec_FM_noisy_j;

% Correct possible sign inversion
if sum(m_fm .* m_rec_FM_clean_j) < 0
    m_rec_FM_clean_j = -m_rec_FM_clean_j;
    m_rec_FM_noisy_j = -m_rec_FM_noisy_j;
end

% Calculate output SNR using the given function
SNR_FM_output = get_aligned_snr(m_rec_FM_clean_j, m_rec_FM_noisy_j);

% Print results
fprintf('\nQuestion j results:\n');
fprintf('Noise scaling factor A_noise_FM = %.6f\n', A_noise_FM);
fprintf('Equivalent noise PSD in AM system = %.6e\n', PSD_noise_AM);
fprintf('Equivalent noise PSD in FM system = %.6e\n', PSD_noise_FM);
fprintf('SNR at FM bandpass filter output = %.2f dB\n', SNR_FM_bpf_actual);
fprintf('SNR at FM demodulator output = %.2f dB\n', SNR_FM_output);

% Plot original and noisy recovered FM signal
% Use the original signal maximum as the plotting scale
scale_FM = max(abs(m_fm));

m_FM_plot = m_fm / scale_FM;
m_rec_FM_noisy_plot = m_rec_FM_noisy_j / scale_FM;

figure;

subplot(2,1,1);
plot(t_fm, m_FM_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Handel Signal');
grid on;
xlim([t_fm(1), t_fm(end)]);
ylim([-1 1]);

subplot(2,1,2);
plot(t_fm, m_rec_FM_noisy_plot, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered FM Signal with AWGN');
grid on;
xlim([t_fm(1), t_fm(end)]);
ylim([-1 1]);

% Play recovered noisy FM audio if needed
% m_rec_FM_noisy_audio = resample(m_rec_FM_noisy_j, Fs, Fs_fm);
% soundsc(m_rec_FM_noisy_audio, Fs);