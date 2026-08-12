function [A_tilde, X, X_f, M, F] = task1(A)
% TASK1 Task 1: Filtrarea frecvențelor spațiale (30 puncte parțiale)
%
% Inputs:
%   A       - Matrix N x N (N = 64) representing pixel intensities of degraded image
%
% Outputs:
%   A_tilde - Filtered spatial image N x N (real part)
%   X       - Image 2D Fourier spectrum matrix N x N (complex)
%   X_f     - Filtered frequency spectrum matrix N x N (complex)
%   M       - Binary low-pass mask matrix N x N
%   F       - Complex exponential matrix N x N (complex)

    N = size(A, 1);
    
    % Subtask 1.1 (10p): Complex exponential matrix F and 2D Fourier spectrum X
    m = (0:N-1)';
    n = (0:N-1);
    F = exp(-2 * pi * 1i * (m * n) / N);
    X = F * A * F;

    % Subtask 1.2 (10p): Binary low-pass mask M and Hadamard product X_f
    M = zeros(N, N);
    row_start = N / 4 + 1;
    row_end = 3 * N / 4;
    col_start = N / 4 + 1;
    col_end = 3 * N / 4;
    M(row_start:row_end, col_start:col_end) = 1;
    
    X_f = X .* M;

    % Subtask 1.3 (10p): Spatial reconstructed image A_tilde
    F_inv = (1 / N) * conj(F);
    A_tilde = real(F_inv * X_f * F_inv);
end
