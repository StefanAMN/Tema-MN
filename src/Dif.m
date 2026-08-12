function dy = Dif(y)
% DIF Computes the 1D numerical derivative of vector y using finite differences.
%   Dependență: Laborator 10 (Diferențiere Numerică)
%
% Input:
%   y  - 1D vector (row or column) of size K
%
% Output:
%   dy - Numerical derivative vector of the same size as y
%
% Mathematical Details:
%   - Forward difference for boundary i = 1: dy(1) = y(2) - y(1)
%   - Central difference for interior points 2 <= i <= K-1: dy(i) = (y(i+1) - y(i-1)) / 2
%   - Backward difference for boundary i = K: dy(K) = y(K) - y(K-1)

    % Ensure y is a vector
    K = length(y);
    dy = zeros(size(y));

    % TODO: Implement Subtask 3.1 helper function Dif
    % Calculate finite difference derivative according to Lab 10 specs.

end
