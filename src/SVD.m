function [U, Sigma, V] = SVD(S)
% SVD Computes the Singular Value Decomposition of matrix S.
%   Dependență: Laborator 7 (Descompunerea în Valori Singulare)
%
% Input:
%   S     - Matrix of size K x K (feature magnitude matrix)
%
% Output:
%   U     - Left singular vectors matrix (K x K)
%   Sigma - Diagonal matrix of singular values (K x K)
%   V     - Right singular vectors matrix (K x K) such that S = U * Sigma * V'

    [K1, K2] = size(S);
    U = eye(K1);
    Sigma = zeros(K1, K2);
    V = eye(K2);

    % TODO: Implement Subtask 4.1 helper function SVD
    % Compute singular value decomposition according to Lab 7 specs.

end
