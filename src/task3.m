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
    S = zeros(K, K);

    % TODO: Subtask 3.1 (10p)
    % Calculate numerical derivative on each row of W_LH using script Dif.m -> G_x
    % Calculate numerical derivative on each column of W_HL using script Dif.m -> G_y

    % TODO: Subtask 3.2 (10p)
    % Synthesize directional features by computing element-wise gradient magnitude:
    % S = sqrt(G_x.^2 + G_y.^2)

end
