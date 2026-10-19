% For aligning the modulating and modulated signal and calculate SNR
function snr_val = get_aligned_snr(ref, test)
    % 1. Unify the length
    len = min(length(ref), length(test));
    ref = ref(1:len); test = test(1:len);
    
    % 2. Find the relative delay
    [corr, lags] = xcorr(ref, test);
    [~, idx] = max(abs(corr));
    best_lag = lags(idx);
    
    % 3. Align the signals
    if best_lag > 0
        ref_aligned = ref(best_lag+1:end);
        test_aligned = test(1:end-best_lag);
    elseif best_lag < 0
        ref_aligned = ref(1:end+best_lag);
        test_aligned = test(-best_lag+1:end);
    else
        ref_aligned = ref;
        test_aligned = test;
    end
    
    % 4. Align the length
    common_len = min(length(ref_aligned), length(test_aligned));
    ref_final = ref_aligned(1:common_len);
    test_final = test_aligned(1:common_len);
    
    % Normalize the power
    ref_final = ref_final / norm(ref_final);
    test_final = test_final / norm(test_final);
    
    % 5. Calculate SNR
    noise_power = sum((ref_final - test_final).^2);
    snr_val = 10 * log10(sum(ref_final.^2) / noise_power);
end