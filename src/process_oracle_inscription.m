function [predicted_class, b, S, A_tilde] = process_oracle_inscription(A, h1, h2, h3)
% PROCESS_ORACLE_INSCRIPTION Main execution pipeline for oracle inscription signal processing.
%
% Inputs:
%   A          - Degraded artifact image pixel intensity matrix (64x64)
%   h1, h2, h3 - Reference binary signatures in database (32x1)
%
% Outputs:
%   predicted_class - Recognized character index (1, 2, or 3)
%   b               - Extracted 32-bit binary signature vector
%   S               - Directional feature magnitude matrix (32x32)
%   A_tilde         - Filtered spatial image matrix (64x64)

    % Step 1: Spatial Frequency Filtering (Task 1)
    [A_tilde, X, X_f, M, F] = task1(A);

    % Step 2: Feature Decoupling via Haar Wavelet (Task 2)
    [W_LH, W_HL, W, H] = task2(A_tilde);

    % Step 3: Asymmetric Feature Extraction (Task 3)
    [S, G_x, G_y] = task3(W_LH, W_HL);

    % Step 4: SVD Compression, Hashing & Classification (Task 4)
    [predicted_class, min_dist, b, v, distances] = task4(S, h1, h2, h3);

end
