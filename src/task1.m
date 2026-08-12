function [A_tilde, X, X_f, M, F] = task1(A)
% TASK1 Task 1: Filtrarea frecvențelor spațiale (30 puncte parțiale)
%
% Input:
%   A       - Matrix N x N (N = 64) representing pixel intensities of degraded image
%
% Outputs:
%   A_tilde - Filtered spatial image N x N (real part)
%   X       - Image 2D Fourier spectrum matrix N x N (complex)
%   X_f     - Filtered frequency spectrum matrix N x N (complex)
%   M       - Binary low-pass mask matrix N x N
%   F       - Complex exponential matrix N x N (complex)

    N = size(A, 1);
    
    % Initialize outputs
    F = zeros(N, N);
    X = zeros(N, N);
    M = zeros(N, N);
    X_f = zeros(N, N);
    A_tilde = zeros(N, N);

    % TODO: Subtask 1.1 (10p)
    % Construct complex exponential matrix F (F_m,n = exp(-2*pi*i*(m-1)*(n-1)/N))
    % Compute 2D Fourier frequency spectrum: X = F * A * F

    % TODO: Subtask 1.2 (10p)
    % Generate binary mask M (low-pass filter): central submatrix (N/2 x N/2) is 1, rest 0
    % Apply Hadamard product: X_f = X .* M

    % TODO: Subtask 1.3 (10p)
    % Reconstruct filtered spatial image: A_tilde = Re(inv(F) * X_f * inv(F))

end
