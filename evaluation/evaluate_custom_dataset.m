<<<<<<< HEAD
function evaluate_custom_dataset(inscriptions_dir, synthetic_count)
% EVALUATE_CUSTOM_DATASET Benchmarks pipeline performance on custom datasets.
%
% Evaluates 20 real inscription image signs (from Kaggle dataset) + 20 synthetic dataset samples.

    if nargin < 1, inscriptions_dir = 'data/inscriptions_20'; end
=======
function evaluate_custom_dataset(hust_dir, synthetic_count)
% EVALUATE_CUSTOM_DATASET Benchmarks pipeline performance on custom datasets.
%
% Evaluates 20 real HUST-OBC images + 20 synthetic dataset samples.

    if nargin < 1, hust_dir = 'data/hust_20'; end
>>>>>>> a0b4c03 (Implement solution for Tasks 1-4, Dif, SVD, and custom dataset benchmark)
    if nargin < 2, synthetic_count = 20; end

    addpath('src');
    addpath('evaluation');

    fprintf('========================================================================\n');
<<<<<<< HEAD
    fprintf('    BENCHMARK PIPELINE PE POZE REALE DE INSCRIPȚII & DATE SINTETICE   \n');
=======
    fprintf('          BENCHMARK PIPELINE PE SETURI DE DATE REAL & SINTETICE         \n');
>>>>>>> a0b4c03 (Implement solution for Tasks 1-4, Dif, SVD, and custom dataset benchmark)
    fprintf('========================================================================\n\n');

    % Set fixed seed for synthetic generation
    rand('seed', 100);
    randn('seed', 100);

    % --- Part 1: Synthetic Dataset Evaluation (20 samples) ---
    fprintf('1. Evaluare pe 20 de eșantioane sintetice...\n');
    synth_correct = 0;
    synth_total = synthetic_count;
    
    for i = 1:synth_total
        target_class = mod(i - 1, 3) + 1;
        noise_lvl = 0.15; % 15% artifact noise
        [A, h1, h2, h3, true_label] = generate_dataset(target_class, noise_lvl);
        
        [pred_class, b, S, A_tilde] = process_oracle_inscription(A, h1, h2, h3);
        if pred_class == true_label
            synth_correct = synth_correct + 1;
        end
    end
    synth_acc = (synth_correct / synth_total) * 100;
    fprintf('   -> Acuratețe eșantioane sintetice: %d/%d (%.1f%%)\n\n', ...
            synth_correct, synth_total, synth_acc);

<<<<<<< HEAD
    % --- Part 2: Real Inscriptions Evaluation (20 samples) ---
    fprintf('2. Evaluare pe 20 de poze reale de inscripții (Kaggle Dataset)...\n');
    real_correct = 0;
    real_total = 0;

    if exist(inscriptions_dir, 'dir')
        img_files = dir(fullfile(inscriptions_dir, '*.jpg'));
        if isempty(img_files)
            img_files = dir(fullfile(inscriptions_dir, '*.png'));
        end
        
        real_total = min(20, length(img_files));
        
        if real_total > 0
            for i = 1:real_total
                img_path = fullfile(inscriptions_dir, img_files(i).name);
=======
    % --- Part 2: HUST-OBC Real Character Evaluation (20 samples) ---
    fprintf('2. Evaluare pe 20 de imagini reale HUST-OBC...\n');
    hust_correct = 0;
    hust_total = 0;

    if exist(hust_dir, 'dir')
        img_files = dir(fullfile(hust_dir, '*.png'));
        if isempty(img_files)
            img_files = dir(fullfile(hust_dir, '*.jpg'));
        end
        
        hust_total = min(20, length(img_files));
        
        if hust_total > 0
            for i = 1:hust_total
                img_path = fullfile(hust_dir, img_files(i).name);
>>>>>>> a0b4c03 (Implement solution for Tasks 1-4, Dif, SVD, and custom dataset benchmark)
                img_raw = imread(img_path);
                if islogical(img_raw)
                    img_double = double(img_raw);
                elseif ndims(img_raw) == 3
                    img_double = double(rgb2gray(img_raw));
                else
                    img_double = double(img_raw);
                end
                
                % Custom 64x64 resize without external package dependencies
                img_resized = simple_resize(img_double, [64 64]);
                A = (img_resized - min(img_resized(:))) / (max(img_resized(:)) - min(img_resized(:)) + 1e-8);
                
                target_label = mod(i - 1, 3) + 1;
                [~, ref_h1, ref_h2, ref_h3, ~] = generate_dataset(target_label, 0);

                [pred_class, b, S, A_tilde] = process_oracle_inscription(A, ref_h1, ref_h2, ref_h3);
                
                dists = [sum(b ~= ref_h1), sum(b ~= ref_h2), sum(b ~= ref_h3)];
                [~, best_match] = min(dists);
                if best_match == target_label
<<<<<<< HEAD
                    real_correct = real_correct + 1;
                end
            end
            real_acc = (real_correct / real_total) * 100;
            fprintf('   -> Acuratețe poze reale de inscripții: %d/%d (%.1f%%)\n\n', ...
                    real_correct, real_total, real_acc);
        else
            fprintf('   -> Nu s-au găsit imagini .jpg / .png în directorul %s\n\n', inscriptions_dir);
        end
    else
        fprintf('   -> Directorul %s nu a fost găsit încă.\n\n', inscriptions_dir);
    end

    fprintf('========================================================================\n');
    fprintf('       REZUMAT BENCHMARK POZE INSCRIPȚII REALE & DATE SINTETICE        \n');
    fprintf('========================================================================\n');
    fprintf('  Set Date Sintetic (20 probe):          %d/%d Acuratețe (%.1f%%)\n', synth_correct, synth_total, synth_acc);
    if real_total > 0
        fprintf('  Poze Inscripții Reale (20 imagini):   %d/%d Acuratețe (%.1f%%)\n', real_correct, real_total, real_acc);
=======
                    hust_correct = hust_correct + 1;
                end
            end
            hust_acc = (hust_correct / hust_total) * 100;
            fprintf('   -> Acuratețe HUST-OBC eșantioane reale: %d/%d (%.1f%%)\n\n', ...
                    hust_correct, hust_total, hust_acc);
        else
            fprintf('   -> Nu s-au găsit imagini .png / .jpg în directorul %s\n\n', hust_dir);
        end
    else
        fprintf('   -> Directorul %s nu a fost găsit încă.\n\n', hust_dir);
    end

    fprintf('========================================================================\n');
    fprintf('           REZUMAT EVALUARE BENCHMARK DATE REAL & SINTETIC             \n');
    fprintf('========================================================================\n');
    fprintf('  Set Date Sintetic (20 probe):   %d/%d Acuratețe (%.1f%%)\n', synth_correct, synth_total, synth_acc);
    if hust_total > 0
        fprintf('  Set Date HUST-OBC (20 imagini): %d/%d Acuratețe (%.1f%%)\n', hust_correct, hust_total, hust_acc);
>>>>>>> a0b4c03 (Implement solution for Tasks 1-4, Dif, SVD, and custom dataset benchmark)
    end
    fprintf('========================================================================\n');
end

function A_res = simple_resize(A, target_size)
    [R, C] = size(A);
    N_r = target_size(1); N_c = target_size(2);
    r_idx = round(linspace(1, R, N_r));
    c_idx = round(linspace(1, C, N_c));
    A_res = A(r_idx, c_idx);
end
