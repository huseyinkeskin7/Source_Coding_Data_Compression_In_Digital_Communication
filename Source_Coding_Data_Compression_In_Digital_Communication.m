%% Hüseyin Berk Keskin HBK
%% 20201706019
%% EEE409 Communication Project - Project 1

clc, clear, close all

letters = {'Z', 'Q', 'J', 'X', 'K', 'V', 'B', 'P', 'G', 'Y', 'F', 'M', 'W', 'C', 'U', 'L', 'D', 'R', 'H', 'S', 'N', 'I', 'O', 'A', 'T', 'E'};
probabilities = [0.074, 0.095, 0.15, 0.131, 0.77, 0.98, 1.5, 1.9, 2.0, 2.0, 2.2, 2.4, 2.0, 2.8, 2.8, 4.0, 4.3, 6.0, 6.1, 6.3, 6.7, 7.0, 7.5, 8.2, 9.1, 13.0]/100;

letters_probabilities_Map = containers.Map(letters, probabilities); % It creates a table for letters and probabilities

% Sorted
[~, sort_Idx] = sort(probabilities, 'descend');
sorted_letters = letters(sort_Idx);
sorted_probabilities = probabilities(sort_Idx);

nodes = create_huffman_tree(sorted_letters, sorted_probabilities); % Creating Huffman tree

huffman_codes = extractCodes(nodes, ''); % Extract to Huffman codes

% Display Huffman codes for each sybol
disp('Letters and Huffman Codes:');
for i = 1:length(sorted_letters)
    letter = sorted_letters{i};
    if isKey(huffman_codes, letter)
        code = huffman_codes(letter);
        fprintf('%s: %s\n', letter, code);
    end
end

%% English written text for Huffman
text = 'itsalwaystooearlytoquit';

original_binary = '';
for i = 1:length(text)
    original_binary = strcat(original_binary, dec2bin(text(i), 8));
end

disp('Original Text Binary:');
disp(original_binary);

original_binary_length = length(original_binary);
fprintf('Original Binary Length: %d bit\n', original_binary_length);


% Coding with Huffman
encoded_text = '';
for i = 1:length(text)
    upped_character = upper(text(i));
    if isKey(huffman_codes, upped_character)
        encoded_text = strcat(encoded_text, huffman_codes(upped_character));
    end
end

disp('Encoded Text:');
disp(encoded_text);

binary_length = length(encoded_text);
fprintf('Encoded text length: %d bit\n', binary_length); % Display encoded text lenght

% Calculating of data compression ratio
original_length = length(text) * 8;
compression_ratio = (original_length - binary_length) / original_length * 100;
fprintf('Data compression ratio: %.2f%%\n', compression_ratio);

% Decoding of text
decoded_text = '';
current_code = '';
reverse_huffman_codes = containers.Map(values(huffman_codes), keys(huffman_codes)); 

for i = 1:length(encoded_text)
    current_code = strcat(current_code, encoded_text(i));
    if isKey(reverse_huffman_codes, current_code)
        decoded_text = strcat(decoded_text, reverse_huffman_codes(current_code)); 
        current_code = ''; 
    end
end

disp('Decoded Text:');
disp(decoded_text);

% Function that creating Huffman tree
function nodes = create_huffman_tree(sorted_letters, sorted_probabilities)
    
    nodes = cell(length(sorted_letters), 1);
    for i = 1:length(sorted_letters)
        nodes{i} = struct('letter', sorted_letters{i}, 'probability', sorted_probabilities(i), 'left', [], 'right', []);
    end

    % Creating Huffman tree
    while length(nodes) > 1

        [~, idx] = sort(cellfun(@(node) node.probability, nodes));
        left = nodes{idx(1)};
        right = nodes{idx(2)};

        new_node = struct('letter', '', 'probability', left.probability + right.probability, ...
                         'left', left, 'right', right);
        nodes = {nodes{idx(3:end)}, new_node};
    end

    nodes = nodes{1};
end

% Extraction of Huffman codes
function codes = extractCodes(node, current_code)
    if isempty(node.left) && isempty(node.right) 
        codes = containers.Map(node.letter, current_code);
        return;
    end
    
    codes = containers.Map();
    codes_left = extractCodes(node.left, strcat(current_code, '0'));
    codes_right = extractCodes(node.right, strcat(current_code, '1'));

    keys_left = keys(codes_left);
    for i = 1:length(keys_left)
        codes(keys_left{i}) = codes_left(keys_left{i});
    end
    
    keys_right = keys(codes_right);
    for i = 1:length(keys_right)
        codes(keys_right{i}) = codes_right(keys_right{i});
    end
end
