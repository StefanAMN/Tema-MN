function [A, h1, h2, h3, true_label] = generate_dataset(label_idx, noise_level)
% GENERATE_DATASET Creates a synthetic oracle inscription image and database signatures.
%
% Inputs:
%   label_idx   - Target character index (1, 2, or 3)
%   noise_level - Noise intensity multiplier (e.g. 0.2)
%
% Outputs:
%   A          - 64x64 pixel intensity matrix representing degraded inscription
%   h1, h2, h3 - 32x1 binary target vectors in database for characters 1, 2, 3
%   true_label - Ground truth label index (1, 2, or 3)

    if nargin < 1, label_idx = 1; end
    if nargin < 2, noise_level = 0.25; end

    N = 64;
    K = N / 2;
    true_label = label_idx;

    % Generate 3 distinct clean character pattern matrices (64x64)
    char_clean = cell(1, 3);
    
    % Character 1: Vertical & Horizontal cross strokes
    C1 = zeros(N, N);
    C1(20:44, 30:34) = 1.0;
    C1(30:34, 16:48) = 1.0;
    char_clean{1} = C1;

    % Character 2: Diagonal X strokes
    C2 = zeros(N, N);
    for i = 16:48
        C2(i, max(1, i-2):min(N, i+2)) = 1.0;
        C2(i, max(1, N-i-1):min(N, N-i+3)) = 1.0;
    end
    char_clean{2} = C2;

    % Character 3: Concentric Diamond / Box stroke
    C3 = zeros(N, N);
    C3(16:20, 16:48) = 1.0; C3(44:48, 16:48) = 1.0;
    C3(16:48, 16:20) = 1.0; C3(16:48, 44:48) = 1.0;
    char_clean{3} = C3;

    % Compute clean reference signatures h1, h2, h3 using the pipeline
    hashes = cell(1, 3);
    for c = 1:3
        % Run reference Task 1-4 pipeline to extract hash b
        ref_b = extract_reference_hash(char_clean{c});
        hashes{c} = ref_b;
    end

    h1 = hashes{1};
    h2 = hashes{2};
    h3 = hashes{3};

    % Add artifact noise (Gaussian noise + random surface crack scratches) to chosen character
    clean_img = char_clean{label_idx};
    noise = noise_level * randn(N, N);
    
    % Add random diagonal crackle artifact lines
    scratch = zeros(N, N);
    scratch(10:54, 10:54) = scratch(10:54, 10:54) + 0.15 * rand(45, 45);
    
    A = clean_img + noise + scratch;
    % Normalize to range [0, 1]
    A = (A - min(A(:))) / (max(A(:)) - min(A(:)) + 1e-8);
end

function b = extract_reference_hash(A_clean)
    N = size(A_clean, 1);
    K = N / 2;

    % Fourier Low-pass Filter
    m = (0:N-1)'; n = (0:N-1);
    F = exp(-2*pi*1i * (m * n) / N);
    X = F * A_clean * F;
    M = zeros(N, N);
    M(N/4+1:3*N/4, N/4+1:3*N/4) = 1;
    X_f = X .* M;
    A_tilde = real(((1/N)*conj(F)) * X_f * ((1/N)*conj(F)));

    % Haar DWT
    H = zeros(N, N);
    for i = 1:K
        H(i, 2*i-1) = 1/sqrt(2); H(i, 2*i) = 1/sqrt(2);
        H(K+i, 2*i-1) = 1/sqrt(2); H(K+i, 2*i) = -1/sqrt(2);
    end
    W = H * A_tilde * H';
    W_LH = W(1:K, K+1:N);
    W_HL = W(K+1:N, 1:K);

    % Asymmetric Derivatives & Gradient Magnitude
    G_x = zeros(K, K);
    for i = 1:K
        y = W_LH(i, :);
        dy = zeros(1, K);
        dy(1) = y(2) - y(1);
        dy(2:K-1) = (y(3:K) - y(1:K-2)) / 2;
        dy(K) = y(K) - y(K-1);
        G_x(i, :) = dy;
    end
    G_y = zeros(K, K);
    for j = 1:K
        y = W_HL(:, j)';
        dy = zeros(1, K);
        dy(1) = y(2) - y(1);
        dy(2:K-1) = (y(3:K) - y(1:K-2)) / 2;
        dy(K) = y(K) - y(K-1);
        G_y(:, j) = dy';
    end
    S = sqrt(G_x.^2 + G_y.^2);

    % SVD & Hashing
    [~, Sigma_mat, ~] = svd(S);
    v = diag(Sigma_mat);
    b = sign(v - mean(v));
    b(b == 0) = 1;
end
