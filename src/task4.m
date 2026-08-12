function [predicted_class, min_dist, b, v, distances] = task4(S, h1, h2, h3)
% TASK4 Task 4: Compresia semnalului, Hashing și Clasificare (20 puncte parțiale)
%
% Inputs:
%   S               - Feature magnitude matrix (K x K, K = 32)
%   h1, h2, h3      - Target binary hash vectors in database (K x 1 or 1 x K, values in {-1, 1})
%
% Outputs:
%   predicted_class - Index of closest matching character in database (1, 2, or 3)
%   min_dist        - Minimum Hamming distance value
%   b               - Generated binary hash code vector (K x 1, values in {-1, 1})
%   v               - Vector of singular values extracted from S (K x 1)
%   distances       - Vector of 3 Hamming distances [d1, d2, d3]

    K = size(S, 1);

    % Subtask 4.1 (10p): SVD decomposition and singular values vector v
    [U, Sigma, V] = svd(S);
    v = diag(Sigma);
    v = v(:); % Ensure column vector

    % Subtask 4.2 (5p): Binary hash code b
    mu = mean(v);
    b = sign(v - mu);
    b(b == 0) = 1; % Ensure values are strictly in {-1, 1}

    % Subtask 4.3 (5p): Hamming distances and classification
    h1 = h1(:); h2 = h2(:); h3 = h3(:);
    d1 = sum(b ~= h1);
    d2 = sum(b ~= h2);
    d3 = sum(b ~= h3);
    
    distances = [d1, d2, d3];
    [min_dist, predicted_class] = min(distances);
end
