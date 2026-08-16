% CHECKER Driver script to verify student implementation and compute full score.
%
% Usage:
%   checker()                          % Runs on default data/practice
%   checker('data/competition')        % Runs on secret competition evaluation set
%   checker('data/practice', 'data/known_symbols')

function checker(test_dir, known_dir)
    if nargin < 1 || isempty(test_dir), test_dir = 'data/practice'; end
    if nargin < 2 || isempty(known_dir), known_dir = 'data/known_symbols'; end

    addpath('src');
    addpath('evaluation');

    fprintf('========================================================================\n');
    fprintf('        EVALUARE TEMA MN: RESTAURARE & CLASIFICARE INSCRIPȚII ORACOL        \n');
    fprintf('========================================================================\n');
    fprintf('Directoriu evaluat: %s\n', test_dir);
    fprintf('Baza de simboluri: %s\n\n', known_dir);

    % --- Faza 1: Încărcare dicționar simboluri cunoscute ---
    known_files = dir(fullfile(known_dir, '*.png'));
    if isempty(known_files)
        known_files = dir(fullfile(known_dir, '*.jpg'));
    end
    num_known = length(known_files);

    if num_known == 0
        fprintf('Eroare: Nu s-au găsit simboluri de referință în %s\n', known_dir);
        return;
    end

    % Sort alphabetically
    [~, sort_idx] = sort({known_files.name});
    known_files = known_files(sort_idx);

    fprintf('Faza 1: Se construiește baza de date cu %d simboluri cunoscute...\n', num_known);

    N_size = 64;
    K_size = N_size / 2;
    known_hashes_ref = zeros(K_size, num_known);
    known_hashes_student = zeros(K_size, num_known);

    for c = 1:num_known
        img_path = fullfile(known_dir, known_files(c).name);
        img_raw = imread(img_path);
        if islogical(img_raw)
            img_double = double(img_raw);
        elseif ndims(img_raw) == 3
            img_double = double(rgb2gray(img_raw));
        else
            img_double = double(img_raw);
        end
        
        img_resized = simple_resize(img_double, [N_size N_size]);
        A = (img_resized - min(img_resized(:))) / (max(img_resized(:)) - min(img_resized(:)) + 1e-8);
        
        ref = build_reference_solution(A, []);
        known_hashes_ref(:, c) = ref.b;
        
        try
            [A_tilde] = task1(A);
            [W_LH, W_HL] = task2(A_tilde);
            [S] = task3(W_LH, W_HL);
            dummy_hashes = zeros(K_size, num_known);
            [~, ~, b_student] = task4(S, dummy_hashes);
            known_hashes_student(:, c) = b_student;
        catch
            known_hashes_student(:, c) = ref.b;
        end
    end

    % --- Faza 2: Căutare imagini de test & Ground Truth ---
    test_files_struct = [];
    labels_map = struct();
    has_labels = false;

    % Check for practice_labels.csv or secret_labels.csv
    csv_candidates = {
        fullfile(test_dir, 'practice_labels.csv'), ...
        fullfile(test_dir, 'secret_labels.csv'), ...
        fullfile(test_dir, 'labels.csv')
    };

    labels_file = '';
    for i = 1:length(csv_candidates)
        if exist(csv_candidates{i}, 'file')
            labels_file = csv_candidates{i};
            break;
        end
    end

    if ~isempty(labels_file)
        has_labels = true;
        fid = fopen(labels_file, 'r');
        header = fgetl(fid); % skip header
        while ~feof(fid)
            line = fgetl(fid);
            if ischar(line) && ~isempty(strtrim(line))
                parts = strsplit(strtrim(line), ',');
                if length(parts) >= 2
                    rel_f = parts{1};
                    c_id = str2double(parts{2});
                    t_name = 'general';
                    if length(parts) >= 3, t_name = parts{3}; end
                    
                    full_p = fullfile(test_dir, rel_f);
                    if exist(full_p, 'file')
                        entry.path = full_p;
                        entry.rel_name = rel_f;
                        entry.true_class = c_id;
                        entry.tier = t_name;
                        test_files_struct = [test_files_struct; entry];
                    end
                end
            end
        end
        fclose(fid);
    end

    if isempty(test_files_struct)
        % Search subdirectories
        sub_dirs = dir(test_dir);
        for s = 1:length(sub_dirs)
            if sub_dirs(s).isdir && ~strcmp(sub_dirs(s).name, '.') && ~strcmp(sub_dirs(s).name, '..')
                sub_path = fullfile(test_dir, sub_dirs(s).name);
                imgs = dir(fullfile(sub_path, '*.png'));
                if isempty(imgs), imgs = dir(fullfile(sub_path, '*.jpg')); end
                for k = 1:length(imgs)
                    entry.path = fullfile(sub_path, imgs(k).name);
                    entry.rel_name = fullfile(sub_dirs(s).name, imgs(k).name);
                    entry.true_class = 0;
                    entry.tier = sub_dirs(s).name;
                    test_files_struct = [test_files_struct; entry];
                end
            end
        end
        
        % Check flat directory
        flat_imgs = dir(fullfile(test_dir, '*.png'));
        if isempty(flat_imgs), flat_imgs = dir(fullfile(test_dir, '*.jpg')); end
        for k = 1:length(flat_imgs)
            entry.path = fullfile(test_dir, flat_imgs(k).name);
            entry.rel_name = flat_imgs(k).name;
            entry.true_class = 0;
            entry.tier = 'general';
            test_files_struct = [test_files_struct; entry];
        end
    end

    num_images = length(test_files_struct);
    if num_images == 0
        fprintf('Eroare: Nu s-au găsit imagini de test în %s\n', test_dir);
        return;
    end

    fprintf('Faza 2: Se evaluează %d imagini de test...\n\n', num_images);

    total_score_sum = 0;
    task_scores_sum = zeros(1, 4);
    correct_classifications = 0;
    
    tier_stats = struct();

    for i = 1:num_images
        img_entry = test_files_struct(i);
        img_raw = imread(img_entry.path);
        
        if islogical(img_raw)
            img_double = double(img_raw);
        elseif ndims(img_raw) == 3
            img_double = double(rgb2gray(img_raw));
        else
            img_double = double(img_raw);
        end
        
        img_resized = simple_resize(img_double, [N_size N_size]);
        A = (img_resized - min(img_resized(:))) / (max(img_resized(:)) - min(img_resized(:)) + 1e-8);
        
        ref = build_reference_solution(A, known_hashes_ref);

        t1_res = struct(); t2_res = struct(); t3_res = struct(); t4_res = struct();

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
                [t4_res.predicted_class, t4_res.min_dist, t4_res.b, t4_res.v, t4_res.distances] = task4(t3_res.S, known_hashes_student);
            else
                [t4_res.predicted_class, t4_res.min_dist, t4_res.b, t4_res.v, t4_res.distances] = task4(ref.S, known_hashes_ref);
            end
        catch
        end

        [img_score, img_task_scores] = compute_score(t1_res, t2_res, t3_res, t4_res, ref);
        
        predicted_cl = ref.predicted_class;
        if isfield(t4_res, 'predicted_class') && ~isempty(t4_res.predicted_class)
            predicted_cl = t4_res.predicted_class;
        end

        % Hamming bit match percentage
        img_match = 100;
        if isfield(t4_res, 'min_dist') && ~isempty(t4_res.min_dist)
            img_match = ((K_size - t4_res.min_dist) / K_size) * 100;
        elseif isfield(t4_res, 'distances') && ~isempty(t4_res.distances)
            img_match = ((K_size - min(t4_res.distances)) / K_size) * 100;
        end

        is_correct = false;
        if img_entry.true_class > 0
            if predicted_cl == img_entry.true_class
                is_correct = true;
                correct_classifications = correct_classifications + 1;
            end
        end

        % Tier statistics tracking
        t_key = img_entry.tier;
        if ~isfield(tier_stats, t_key)
            tier_stats.(t_key).total = 0;
            tier_stats.(t_key).correct = 0;
            tier_stats.(t_key).score = 0;
        end
        tier_stats.(t_key).total = tier_stats.(t_key).total + 1;
        tier_stats.(t_key).score = tier_stats.(t_key).score + img_score;
        if is_correct
            tier_stats.(t_key).correct = tier_stats.(t_key).correct + 1;
        end

        if img_entry.true_class > 0
            match_status = sprintf('Clasa Reală: %2d | Predicție: %2d [%s]', ...
                                   img_entry.true_class, predicted_cl, ...
                                   ternary(is_correct, 'OK', 'MISS'));
        else
            match_status = sprintf('Predicție: %2d', predicted_cl);
        end

        fprintf('  [%-10s] %-20s -> %s (Bit Match: %5.1f%%, Scor: %5.2f/90)\n', ...
                img_entry.tier, img_entry.rel_name, match_status, img_match, img_score);
        
        total_score_sum = total_score_sum + img_score;
        task_scores_sum = task_scores_sum + img_task_scores;
    end

    avg_total_score = total_score_sum / num_images;
    avg_task_scores = task_scores_sum / num_images;

    fprintf('\n------------------------------------------------------------------------\n');
    fprintf('REZULTATE EVALUARE PE TIERS:\n');
    tier_names = fieldnames(tier_stats);
    for tn = 1:length(tier_names)
        t_name = tier_names{tn};
        t_data = tier_stats.(t_name);
        if has_labels
            fprintf('  • %-12s : %2d/%2d corecte (Acuratețe %5.1f%%) | Scor Mediu: %5.2f/90\n', ...
                    t_name, t_data.correct, t_data.total, (t_data.correct / t_data.total)*100, t_data.score / t_data.total);
        else
            fprintf('  • %-12s : %2d mostre evaluate | Scor Mediu: %5.2f/90\n', ...
                    t_name, t_data.total, t_data.score / t_data.total);
        end
    end

    if has_labels
        overall_acc = (correct_classifications / num_images) * 100;
        fprintf('\nACURATEȚE GLOBALĂ CLASIFICARE (TOP-1): %d/%d (%.2f%%)\n', ...
                correct_classifications, num_images, overall_acc);
    end

    fprintf('------------------------------------------------------------------------\n');
    fprintf('MEDIE PUNCTAJE PARȚIALE PE TASK-URI:\n');
    fprintf('  Task 1 (Filtrare Fourier 2D):              %5.2f / 30 puncte\n', avg_task_scores(1));
    fprintf('  Task 2 (Transformata Wavelet Haar 2D):      %5.2f / 20 puncte\n', avg_task_scores(2));
    fprintf('  Task 3 (Diferențiere Numerică Asimetrică): %5.2f / 20 puncte\n', avg_task_scores(3));
    fprintf('  Task 4 (SVD, Hashing & Clasificare):        %5.2f / 20 puncte\n', avg_task_scores(4));
    fprintf('------------------------------------------------------------------------\n');
    fprintf('  PUNCTAJ TOTAL MEDIU:                       %5.2f / 90 puncte\n', avg_total_score);
    fprintf('========================================================================\n');
endfunction

function out = ternary(cond, val_true, val_false)
    if cond
        out = val_true;
    else
        out = val_false;
    end
endfunction

function A_res = simple_resize(A, target_size)
    [R, C] = size(A);
    N_r = target_size(1); N_c = target_size(2);
    r_idx = round(linspace(1, R, N_r));
    c_idx = round(linspace(1, C, N_c));
    A_res = A(r_idx, c_idx);
endfunction

function ref = build_reference_solution(A, known_hashes)
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

    ref.v = v; ref.b = b; 
    
    if ~isempty(known_hashes)
        C = size(known_hashes, 2);
        dists = zeros(1, C);
        for c = 1:C
            dists(c) = sum(b(:) ~= known_hashes(:, c));
        end
        [min_dist, predicted_class] = min(dists);
        ref.distances = dists;
        ref.min_dist = min_dist;
        ref.predicted_class = predicted_class;
    else
        ref.distances = [];
        ref.min_dist = [];
        ref.predicted_class = [];
    end
endfunction