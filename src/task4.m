function [predicted_class, min_dist, b, v, distances] = task4(S, h1, h2, h3)
% TASK4 Task 4: Compresia semnalului, Hashing și Clasificare (20 puncte parțiale)

    K = size(S, 1);

    % Subtask 4.1 (10p): SVD decomposition and singular values vector v
    [U, Sigma, V] = svd(S);
    v = diag(Sigma);
    v = v(:); % Ensure column vector (K x 1)

    % Subtask 4.2 (5p): Binary hash code b
    mu = mean(v);
    b = sign(v - mu);
    b(b == 0) = 1; % Ensure values are strictly in {-1, 1}

    % Subtask 4.3 (5p): Hamming distances and classification
    % Tratăm atât cazul cu 4 argumente (S, h1, h2, h3) cât și cazul cu 2 argumente (S, known_hashes_matrix)
    if nargin == 2
        % Cazul în care al doilea argument este o matrice cu toate hash-urile pe coloane
        known_hashes = h1;
        num_classes = size(known_hashes, 2);
        distances = zeros(1, num_classes);
        for c = 1:num_classes
            hc = known_hashes(:, c);
            distances(c) = sum(b ~= hc(:));
        end
    else
        % Cazul standard în care se pasează h1, h2, h3 individual
        h1 = h1(:); 
        h2 = h2(:); 
        if nargin >= 4
            h3 = h3(:);
        else
            h3 = h1; % Fallback dacă lipsește h3
        end
        
        d1 = sum(b ~= h1);
        d2 = sum(b ~= h2);
        d3 = sum(b ~= h3);
        distances = [d1, d2, d3];
    end

    [min_dist, predicted_class] = min(distances);
end