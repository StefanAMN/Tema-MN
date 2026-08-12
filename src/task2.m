function [W_LH, W_HL, W, H] = task2(A_tilde)
% TASK2 Task 2: Decuplarea caracteristicilor cu Transformata Wavelet (20 puncte parțiale)
%
% Inputs:
%   A_tilde - Filtered spatial image matrix N x N (N = 64)
%
% Outputs:
%   W_LH    - Top-right submatrix (N/2 x N/2) for horizontal variations
%   W_HL    - Bottom-left submatrix (N/2 x N/2) for vertical variations
%   W       - Full Haar wavelet coefficients matrix N x N
%   H       - Haar transformation matrix N x N

    N = size(A_tilde, 1);
    K = N / 2;
    
    % Subtask 2.1 (10p): Construct Haar transformation matrix H and compute W
    H = zeros(N, N);
    for i = 1:K
        % Scaling basis vectors (top half)
        H(i, 2*i-1) = 1 / sqrt(2);
        H(i, 2*i)   = 1 / sqrt(2);
        % Wavelet basis vectors (bottom half)
        H(K+i, 2*i-1) = 1 / sqrt(2);
        H(K+i, 2*i)   = -1 / sqrt(2);
    end
    
    W = H * A_tilde * H';

    % Subtask 2.2 (10p): Extract submatrices W_LH and W_HL
    W_LH = W(1:K, K+1:N);
    W_HL = W(K+1:N, 1:K);
end
