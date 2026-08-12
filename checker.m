function checker()
% CHECKER Driver script to verify student implementation and compute partial score.
%
% Evaluates across Task 1 (30p), Task 2 (20p), Task 3 (20p), and Task 4 (20p).
% Modified to run on real images from data/inscriptions_20.

    addpath('src');
    addpath('evaluation');
    
    fprintf('========================================================================\n');
    fprintf('       EVALUARE TEMA MN: RESTAURARE & CLASIFICARE INSCRIPȚII ORACOL       \n');
    fprintf('========================================================================\n\n');

    inscriptions_dir = 'data/inscriptions_20';
    img_files = dir(fullfile(inscriptions_dir, '*.jpg'));
    if isempty(img_files)
        img_files = dir(fullfile(inscriptions_dir, '*.png'));
    end
    
    num_images = length(img_files);
    if num_images == 0
        fprintf('Eroare: Nu s-au găsit imagini în %s\n', inscriptions_dir);
        return;
    end
    
    fprintf('Se evaluează %d imagini reale...\n', num_images);
    
    total_score_sum = 0;
    task_scores_sum = zeros(1, 4);

    % Set seed for reproducibility of reference hashes
    rand('seed', 42);
    randn('seed', 42);

    for i = 1:num_images
        img_path = fullfile(inscriptions_dir, img_files(i).name);
        img_raw = imread(img_path);
        
        % Convert to grayscale
        if islogical(img_raw)
            img_double = double(img_raw);
        elseif ndims(img_raw) == 3
            img_double = double(rgb2gray(img_raw));
        else
            img_double = double(img_raw);
        end
        
        % Resize to 64x64
        img_resized = simple_resize(img_double, [64 64]);
        
        % Normalize 0-1
        A = (img_resized - min(img_resized(:))) / (max(img_resized(:)) - min(img_resized(:)) + 1e-8);
        
        N = 64;
        K = N / 2;
        
        h1 = sign(randn(K, 1)); h1(h1 == 0) = 1;
        h2 = sign(randn(K, 1)); h2(h2 == 0) = 1;
        h3 = sign(randn(K, 1)); h3(h3 == 0) = 1;

        % Build reference solution
        ref = build_reference_solution(A, h1, h2, h3);

        % --- Run Student Implementation ---
        t1_res = struct();
        t2_res = struct();
        t3_res = struct();
        t4_res = struct();

        % We suppress the individual task success/error messages to keep console minimal
        try
            [t1_res.A_tilde, t1_res.X, t1_res.X_f, t1_res.M, t1_res.F] = task1(A);
        catch
        end

        try
            if isfield(t1_res, 'A_tilde')
                [t2_res.W_LH, t2_res.W_HL, t2_res.W, t2_res.H] = task2(t1_res.A_tilde);
            else
                [t2_res.W_LH, t2_res.W_HL, t2_res.W, t2_res.H] = task2(ref.A_tilde);
            end
        catch
        end

        try
            if isfield(t2_res, 'W_LH') && isfield(t2_res, 'W_HL')
                [t3_res.S, t3_res.G_x, t3_res.G_y] = task3(t2_res.W_LH, t2_res.W_HL);
            else
                [t3_res.S, t3_res.G_x, t3_res.G_y] = task3(ref.W_LH, ref.W_HL);
            end
        catch
        end

        try
            if isfield(t3_res, 'S')
                [t4_res.predicted_class, t4_res.min_dist, t4_res.b, t4_res.v, t4_res.distances] = ...
                    task4(t3_res.S, h1, h2, h3);
            else
                [t4_res.predicted_class, t4_res.min_dist, t4_res.b, t4_res.v, t4_res.distances] = ...
                    task4(ref.S, h1, h2, h3);
            end
        catch
        end

        % Evaluate score for this image
        [img_score, img_task_scores] = compute_score(t1_res, t2_res, t3_res, t4_res, ref);
        
        total_score_sum = total_score_sum + img_score;
        task_scores_sum = task_scores_sum + img_task_scores;
    end
    
    avg_total_score = total_score_sum / num_images;
    avg_task_scores = task_scores_sum / num_images;

    fprintf('\n------------------------------------------------------------------------\n');
    fprintf('REZULTATE EVALUARE (MEDIE PE %d IMAGINI REALE):\n', num_images);
    fprintf('  Task 1 (Filtrare Fourier 2D):           %5.2f / 30 puncte\n', avg_task_scores(1));
    fprintf('  Task 2 (Transformata Wavelet Haar):     %5.2f / 20 puncte\n', avg_task_scores(2));
    fprintf('  Task 3 (Diferențiere Numerică Asimetrică): %5.2f / 20 puncte\n', avg_task_scores(3));
    fprintf('  Task 4 (SVD, Hashing & Clasificare):     %5.2f / 20 puncte\n', avg_task_scores(4));
    fprintf('------------------------------------------------------------------------\n');
    fprintf('  PUNCTAJ TOTAL OBTINUT:                 %5.2f / 90 puncte\n', avg_total_score);
    fprintf('========================================================================\n');
end

function A_res = simple_resize(A, target_size)
    [R, C] = size(A);
    N_r = target_size(1); N_c = target_size(2);
    r_idx = round(linspace(1, R, N_r));
    c_idx = round(linspace(1, C, N_c));
    A_res = A(r_idx, c_idx);
end

function ref = build_reference_solution(A, h1, h2, h3)
    N = size(A, 1);
    K = N / 2;

    % Task 1 reference
    m = (0:N-1)';
    n = (0:N-1);
    F = exp(-2*pi*1i * (m * n) / N);
    X = F * A * F;

    M = zeros(N, N);
    M(N/4+1 : 3*N/4, N/4+1 : 3*N/4) = 1;
    X_f = X .* M;

    F_inv = (1/N) * conj(F);
    A_tilde = real(F_inv * X_f * F_inv);

    ref.F = F; ref.X = X; ref.M = M; ref.X_f = X_f; ref.A_tilde = A_tilde;

    % Task 2 reference
    H = zeros(N, N);
    for i = 1:K
        H(i, 2*i-1) = 1/sqrt(2);
        H(i, 2*i)   = 1/sqrt(2);
        H(K+i, 2*i-1) = 1/sqrt(2);
        H(K+i, 2*i)   = -1/sqrt(2);
    end
    W = H * A_tilde * H';
    W_LH = W(1:K, K+1:N);
    W_HL = W(K+1:N, 1:K);

    ref.H = H; ref.W = W; ref.W_LH = W_LH; ref.W_HL = W_HL;

    % Task 3 reference
    G_x = zeros(K, K);
    for i = 1:K
        y = W_LH(i, :);
        dy = zeros(1, K);
        dy(1) = y(2) - y(1);
        dy(2:K-1) = (y(3:K) - y(1:K-2)) / 2;
        dy(K) = y(K) - y(K-1);
        G_x(i, :) = dy;
    end

    G_y = zeros(K, K);
    for j = 1:K
        y = W_HL(:, j)';
        dy = zeros(1, K);
        dy(1) = y(2) - y(1);
        dy(2:K-1) = (y(3:K) - y(1:K-2)) / 2;
        dy(K) = y(K) - y(K-1);
        G_y(:, j) = dy';
    end
    S = sqrt(G_x.^2 + G_y.^2);

    ref.G_x = G_x; ref.G_y = G_y; ref.S = S;

    % Task 4 reference
    [U_mat, Sigma_mat, V_mat] = svd(S);
    v = diag(Sigma_mat);
    mu = mean(v);
    b = sign(v - mu);
    b(b == 0) = 1;

    d1 = sum(b(:) ~= h1(:));
    d2 = sum(b(:) ~= h2(:));
    d3 = sum(b(:) ~= h3(:));
    dists = [d1, d2, d3];
    [min_dist, predicted_class] = min(dists);

    ref.v = v; ref.b = b; ref.distances = dists;
    ref.min_dist = min_dist; ref.predicted_class = predicted_class;
end
