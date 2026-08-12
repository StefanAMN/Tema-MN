function [predicted_class, min_dist, b, v, distances] = task4(S, known_hashes)
% TASK4 Task 4: Compresia semnalului, Hashing și Clasificare (20 puncte parțiale)
%
% Inputs:
%   S               - Feature magnitude matrix (K x K, K = 32)
%   known_hashes    - Matrix of size K x C, where each column is a binary hash for a known class
%
% Outputs:
%   predicted_class - Index of closest matching character in database
%   min_dist        - Minimum Hamming distance value
%   b               - Generated binary hash code vector (K x 1)
%   v               - Vector of singular values extracted from S (K x 1)
%   distances       - Vector of C Hamming distances

    K = size(S, 1);
    C = size(known_hashes, 2);
    v = zeros(K, 1);
    b = zeros(K, 1);
    distances = zeros(1, 3);
    min_dist = K;
    predicted_class = 1;

    % TODO: Subtask 4.1 (10p)
    % Perform Singular Value Decomposition using helper function SVD.m: S = U * Sigma * V'
    % Extract diagonal of matrix Sigma to form vector v (K x 1)

    % TODO: Subtask 4.2 (5p)
    % Compute mean mu = mean(v)
    % Transform vector v into binary hash code b in {-1, 1}^K: b_i = sign(v_i - mu)

    % TODO: Subtask 4.3 (5p)
    % Compute Hamming distance between b and target vectors (h1, h2, h3)
    % Identify closest character index (1, 2, or 3) with minimum distance

end
