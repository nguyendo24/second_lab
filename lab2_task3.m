% Load plaintext, ciphertext, traces, and sbox
load 'aes_power_data.mat';
bytes_recovered = zeros (1,16);

% For Task 3, n_traces = 20, 50, 100, and 200
n_traces = 200;

traces = traces (1:n_traces, :);

% Number of samples in each power trace
traceSize = 40000;

byteBegin = 1;
byteEnd = 16;
keyGuessBegin = 0;
keyGuessEnd = 255;

for BYTE=byteBegin:byteEnd

    % Initialize DoM and power guess matrices
    DoM(1,:) = zeros(1,traceSize);
    DPAguess = zeros(n_traces,256);
    
    for K = keyGuessBegin:keyGuessEnd                             
        
        % XOR plaintext with key guess before putting in sbox
        DPAguess(:,K+1)=bitxor(plain_text(1:n_traces,BYTE),K);

        % Putting in sbox
        DPAguess(:,K+1)=sbox(DPAguess(:,K+1)+1);
        
        group0 = zeros(1,traceSize);
        group1 = zeros(1,traceSize);
        
        
        n_Traces_Group0  = 0;
        n_Traces_Group1  = 0;
           
        
        % Loop to put the sbox output into bins based on LSB 
        for L = 1:n_traces
            
            firstByte = bitget(DPAguess(L,K+1),1);
            
            if firstByte == 1
                
                group0(1,:) = group0(1,:) + traces(L,:);
                n_Traces_Group0 = n_Traces_Group0 + 1;
            else
                group1(1,:) = group1(1,:) + traces(L,:);
                n_Traces_Group1 = n_Traces_Group1 + 1;
            end
        end
        
        % Find the average of each bin
        group0(1,:) = group0(1,:) / n_Traces_Group0; 
        group1(1,:) = group1(1,:) / n_Traces_Group1; 
        
        % Find DoM of the bins
        DoM(K+1,:) = abs(group0(1,:)-group1(1,:)); 
    end
    

   % Find the indices for the max value in the DoM
    [traceDiffMax_X,traceDiffMax_Y]=ind2sub(size(DoM), find(DoM==max(DoM(:))));
    
   % Place the max value in the key guess array
   bytes_recovered(1,BYTE) = traceDiffMax_X - 1;

end    
    
% Putting key guess in hex and decimal to use for accuracy calculations
key_guessHex = dec2hex(bytes_recovered);
key_guessBi = dec2bin(bytes_recovered);

% Putting actual key in hex, decimal, and binary to use for accuracy calculations
true_keyHex = [00, 11, 22, 33, 44, 55, 66, 77, 88, 99, 'AA', 'BB', 'CC', 'DD', 'EE', 'FF'];
true_keyDec = [0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221, 238, 255];
true_keyBi = dec2bin(true_keyDec);

% Calculate the difference between the actual key and the key guess
key_diff = true_keyBi - key_guessBi;

% Calculate the sum of key difference
total = sum(sum(key_diff(:,:)~=0));

% Calculate the accuracy
accuracy = (128-total)/128 * 100;