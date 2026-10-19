function b = design_fir_filter(type, Bw, Fs, fc)
% Function for designing FIR filter
%
% Input variables：
%   type  - 'lowpass' or 'bandpass'
%   Bw    - Bandwidth of the input signal in Hz
%   Fs    - Sampling frequency in Hz
%   fc    - Carrier frequency in Hz, not necessary for lowpass filter
    
    order = 100; % order of the FIR filter

    % Verify the variable type
    type = lower(type);
    if ~ismember(type, {'lowpass', 'bandpass'})
        error('type must be "lowpass" or "bandpass"');
    end

    if nargin <= 3 && strcmpi(type, 'bandpass') % Check the number of input arguments
        error('The carrier frequency is missing for designing the bandpass filter')
    end

    if nargin < 3
        error('At least three input variables are needed')
    end
        
    % Design the filter
    if strcmp(type, 'lowpass')
        Wn = Bw * 2 / Fs; % Normalize the frequency to the range from 0 Hz to 1 Hz
        b = fir1(order, Wn, 'low');
    else
        Wn = [fc - Bw/2, fc + Bw/2] * 2 / Fs; % Normalize the frequency to the range from 0 Hz to 1 Hz
        b = fir1(order, Wn, 'bandpass');
    end
end

% Use the following command to plot the frequency response of the filter
% freqz(b, 1, [], Fs)

% Use the following command to perform filtering:
% filtered_signal = filter(b, 1, input_signal);

% Feel free to change the names of the variables above to facilitate coding