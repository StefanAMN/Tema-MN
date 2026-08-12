function [S, G_x, G_y] = task3(W_LH, W_HL)
% TASK3 Task 3: Extragerea asimetrică a trăsăturilor (20 puncte parțiale)
%
% Inputs:
%   W_LH - Submatrix (N/2 x N/2) containing horizontal detail coefficients
%   W_HL - Submatrix (N/2 x N/2) containing vertical detail coefficients
%
% Outputs:
%   S    - Synthesized feature magnitude matrix (N/2 x N/2)
%   G_x  - Horizontal numerical derivative matrix (N/2 x N/2)
%   G_y  - Vertical numerical derivative matrix (N/2 x N/2)

    K = size(W_LH, 1);
    G_x = zeros(K, K);
    G_y = zeros(K, K);

    % Subtask 3.1 (10p): Compute G_x (row-wise on W_LH) and G_y (col-wise on W_HL)
    for i = 1:K
        y = W_LH(i, :);
        dy = zeros(1, K);
        dy(1) = y(2) - y(1);
        dy(2:K-1) = (y(3:K) - y(1:K-2)) / 2;
        dy(K) = y(K) - y(K-1);
        G_x(i, :) = dy;
    end

    for j = 1:K
        y = W_HL(:, j)';
        dy = zeros(1, K);
        dy(1) = y(2) - y(1);
        dy(2:K-1) = (y(3:K) - y(1:K-2)) / 2;
        dy(K) = y(K) - y(K-1);
        G_y(:, j) = dy';
    end

    % Subtask 3.2 (10p): Compute gradient magnitude S
    S = sqrt(G_x.^2 + G_y.^2);
end
