function [W_LH, W_HL, W, H] = task2(A_tilde)
% TASK2 Task 2: Decuplarea caracteristicilor cu Transformata Wavelet (20 puncte parțiale)
%
% Input:
%   A_tilde - Filtered spatial image matrix N x N (N = 64)
%
% Outputs:
%   W_LH    - Top-right submatrix (N/2 x N/2) for horizontal variations
%   W_HL    - Bottom-left submatrix (N/2 x N/2) for vertical variations
%   W       - Full Haar wavelet coefficients matrix N x N
%   H       - Haar transformation matrix N x N

    N = size(A_tilde, 1);
    K = N / 2;
    
    % Initialize outputs
    H = zeros(N, N);
    W = zeros(N, N);
    W_LH = zeros(K, K);
    W_HL = zeros(K, K);

    % TODO: Subtask 2.1 (10p)
    % Construct Haar transformation matrix H (N x N)
    % Calculate wavelet coefficient matrix: W = H * A_tilde * H'

    % TODO: Subtask 2.2 (10p)
    % Extract submatrices of size (N/2 x N/2):
    % W_LH (top-right quadrant, rows 1..N/2, cols N/2+1..N)
    % W_HL (bottom-left quadrant, rows N/2+1..N, cols 1..N/2)

end
