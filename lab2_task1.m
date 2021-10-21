% Load plaintext, ciphertext, traces, and sbox
load 'aes_power_data.mat';
bytes_recovered = zeros (1,16);

% For Task 1, n_traces = 200
n_traces = 200; 
traces = traces (1:n_traces, :);

% Number of samples in each power trace
traceSize = 40000;

byteBegin = 1;
byteEnd = 16;
keyGuessBegin = 0;
keyGuessEnd = 255;

% Attempting to find the 16th byte of the key
currentKeyByte = 16;

% Initialize DoM and power guess matrices
DoM(1,:) = zeros(1,traceSize);
DPAguess = zeros(n_traces,256);

for K = keyGuessBegin:keyGuessEnd    
        
        
        % XOR plaintext with key guess before putting in sbox
        DPAguess(:,K+1)=bitxor(plain_text(1:n_traces,currentKeyByte),K);

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
        groupDiff = abs(group0(1,:)-group1(1,:));
        DoM(K+1,:) = groupDiff;

end
    

[traceDiffMax_X,traceDiffMax_Y] = find(DoM==max(DoM(:)));

bytes_recovered(1:length(traceDiffMax_X),currentKeyByte) = traceDiffMax_X - 1;
   
idxmin = max(traceDiffMax_Y (:));


%% Sample code to make plots 
OFFSSET= 192 ; % for N=64, 0 , 64. 128, 192
N=8; % for an NxN plot
for i = 1:N
    for j = 1:N
        subplot(N,N,(i-1)*N+j)
        plot(DoM ((i-1)*N+j+OFFSSET, :) )
        %plot(DoM ((i-1)*N+j+OFFSSET, :), '-p', 'MarkerIndices',idxmin,'MarkerFaceColor','red' )
        
    end
end

