function [predicted_class, min_dist, b, v, distances] = task4(S, known_hashes, h2, h3)
% TASK4 Task 4: Compresia semnalului, Hashing și Clasificare (20 puncte parțiale)
%
% Inputs:
%   S               - Feature magnitude matrix (K x K, K = 32)
%   known_hashes    - Matrix of size K x C (or h1 vector if 4 args are passed)
%
% Outputs:
%   predicted_class - Index of closest matching character in database
%   min_dist        - Minimum Hamming distance value
%   b               - Generated binary hash code vector (K x 1)
%   v               - Vector of singular values extracted from S (K x 1)
%   distances       - Vector of C Hamming distances

    % Tratare compatibilitate antet (2 sau 4 argumente)
    if nargin == 4
        known_hashes = [known_hashes(:), h2(:), h3(:)];
    end

    K = size(S, 1);
    C = size(known_hashes, 2);

    % Initializari
    v = zeros(K, 1);
    b = zeros(K, 1);
    distances = zeros(1, C);
    min_dist = K;
    predicted_class = 1;

    % TODO: Subtask 4.1 (10p)
    % Perform Singular Value Decomposition using SVD: S = U * Sigma * V'
    % Extract diagonal of matrix Sigma to form vector v (K x 1)

    % TODO: Subtask 4.2 (5p)
    % Compute mean mu = mean(v)
    % Transform vector v into binary hash code b in {-1, 1}^K: b_i = sign(v_i - mu)

    % TODO: Subtask 4.3 (5p)
    % Compute Hamming distance between b and target vectors
    % Identify closest character index with minimum distance

end