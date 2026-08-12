function [total_score, task_scores] = compute_score(t1_res, t2_res, t3_res, t4_res, ref)
% COMPUTE_SCORE Calculates evaluation score out of 90 partial points.
%
% Inputs:
%   t1_res - Struct with Task 1 student outputs {A_tilde, X, X_f, M, F}
%   t2_res - Struct with Task 2 student outputs {W_LH, W_HL, W, H}
%   t3_res - Struct with Task 3 student outputs {S, G_x, G_y}
%   t4_res - Struct with Task 4 student outputs {predicted_class, min_dist, b, v, distances}
%   ref    - Struct with ground truth reference outputs
%
% Outputs:
%   total_score - Sum of partial points earned (out of 90)
%   task_scores - Array of points earned per task [Task1_pts, Task2_pts, Task3_pts, Task4_pts]

    tol = 1e-4;
    task_scores = zeros(1, 4);

    % --- Task 1 Evaluation (30 points) ---
    t1_pts = 0;
    if isfield(t1_res, 'F') && isfield(t1_res, 'X') && ...
       norm(t1_res.F - ref.F, 'fro') < tol && norm(t1_res.X - ref.X, 'fro') < tol
        t1_pts = t1_pts + 10; % Subtask 1.1 (10p)
    end
    if isfield(t1_res, 'M') && isfield(t1_res, 'X_f') && ...
       norm(t1_res.M - ref.M, 'fro') < tol && norm(t1_res.X_f - ref.X_f, 'fro') < tol
        t1_pts = t1_pts + 10; % Subtask 1.2 (10p)
    end
    if isfield(t1_res, 'A_tilde') && norm(t1_res.A_tilde - ref.A_tilde, 'fro') < tol
        t1_pts = t1_pts + 10; % Subtask 1.3 (10p)
    end
    task_scores(1) = t1_pts;

    % --- Task 2 Evaluation (20 points) ---
    t2_pts = 0;
    if isfield(t2_res, 'H') && isfield(t2_res, 'W') && ...
       norm(t2_res.H - ref.H, 'fro') < tol && norm(t2_res.W - ref.W, 'fro') < tol
        t2_pts = t2_pts + 10; % Subtask 2.1 (10p)
    end
    if isfield(t2_res, 'W_LH') && isfield(t2_res, 'W_HL') && ...
       norm(t2_res.W_LH - ref.W_LH, 'fro') < tol && norm(t2_res.W_HL - ref.W_HL, 'fro') < tol
        t2_pts = t2_pts + 10; % Subtask 2.2 (10p)
    end
    task_scores(2) = t2_pts;

    % --- Task 3 Evaluation (20 points) ---
    t3_pts = 0;
    if isfield(t3_res, 'G_x') && isfield(t3_res, 'G_y') && ...
       norm(t3_res.G_x - ref.G_x, 'fro') < tol && norm(t3_res.G_y - ref.G_y, 'fro') < tol
        t3_pts = t3_pts + 10; % Subtask 3.1 (10p)
    end
    if isfield(t3_res, 'S') && norm(t3_res.S - ref.S, 'fro') < tol
        t3_pts = t3_pts + 10; % Subtask 3.2 (10p)
    end
    task_scores(3) = t3_pts;

    % --- Task 4 Evaluation (20 points) ---
    t4_pts = 0;
    if isfield(t4_res, 'v') && norm(t4_res.v - ref.v) < tol
        t4_pts = t4_pts + 10; % Subtask 4.1 (10p)
    end
    if isfield(t4_res, 'b') && isequal(t4_res.b(:), ref.b(:))
        t4_pts = t4_pts + 5;  % Subtask 4.2 (5p)
    end
    if isfield(t4_res, 'predicted_class') && t4_res.predicted_class == ref.predicted_class
        t4_pts = t4_pts + 5;  % Subtask 4.3 (5p)
    end
    task_scores(4) = t4_pts;

    total_score = sum(task_scores);
end
