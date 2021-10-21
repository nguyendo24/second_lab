load('C:\Users\Nhat\Documents\Learning\Matlab\assignment2\aes_power_data.mat')

bytes_recovered = zeros (1,16);
n_traces = 20; 
traces = traces (1:n_traces, :); 
traceSize = max(size(traces(1,:))); %40000

offset = 0;
segmentLength = 40000; 

columns = 16;
rows = n_traces;



% variables declaration
byteStart = 1;
byteEnd = 16;
keyCandidateStart = 0;
keyCandidateStop = 255;
solvedKey = zeros(1,byteEnd);

% for every byte in the key we will do
for BYTE=byteStart:byteEnd

    % Create the hypothesis matrix (dimensions: 
    % rows = numberOfTraces, columns = 256). 
    % The number 256 represents all possible bytes (e.g., 0x00..0xFF)    
    DoM(1,:) = zeros(1,traceSize);
    Hypothesis = zeros(n_traces,256);
    
    for K = keyCandidateStart:keyCandidateStop                             
        
        % Calculate the hypothesis
        Hypothesis(:,K+1)=bitxor(plain_text(1:20,BYTE),K);
        Hypothesis(:,K+1)=sbox(Hypothesis(:,K+1)+1);
        
        group1 = zeros(1,segmentLength);
        group2 = zeros(1,segmentLength);
        
        % separate traces in two groups
        nbTracesG1 = 0;
        nbTracesG2 = 0;
           
        %for all traces put into one or other group based on 
        % predicted Least Significant Bit
        for L = 1:n_traces
            
            % get the expected least significant bit from the hypothesis
            firstByte = bitget(Hypothesis(L,K+1),1);
            
            if firstByte == 1
                
                group1(1,:) = group1(1,:) + traces(L,:);
                nbTracesG1 = nbTracesG1 + 1;
            else
                group2(1,:) = group2(1,:) + traces(L,:);
                nbTracesG2 = nbTracesG2 + 1;
            end
        end
        
        % Calculate the average of the groups
        group1(1,:) = group1(1,:) / nbTracesG1; % average of group 1
        group2(1,:) = group2(1,:) / nbTracesG2; % average of group 2
        
        DoM(K+1,:) = abs(group1(1,:)-group2(1,:)); % Difference of means
    end
    
   % Retrieve the row that has the peak of the DoM
   % 1/ Find the max of all the row
   % 2/ Retrieve the row and column index of the max values
   [X,Y]=ind2sub(size(DoM), find(DoM==max(DoM(:))));
    
   % get the right key for the current key byte guess
   solvedKey(1,BYTE) = X - 1;

end    
    

% fprintf('%x ', solvedKey);   

% convert solved key to decimal 
solvedKey_hex = dec2hex(solvedKey);

% convert solved key to binary
solvedKey_bi = dec2bin(solvedKey);

% original key in hexadecimal
originalKey = [00, 11, 22, 33, 44, 55, 66, 77, 88, 99, 'AA', 'BB', 'CC', 'DD', 'EE', 'FF'];

% original key in decimal
originalKey_dec = [0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221, 238, 255];

% original key in binary
originalKey_bi = dec2bin(originalKey_dec);

% different between original key and solved key in binary
result = originalKey_bi - solvedKey_bi;

% aggregate non-zeros number
nonzeros = sum(result' ~=0);

% sum the number of non-zeros element
s = sum(nonzeros(1,:));

% calculate the accuracy
accuracy = (128-s)/128 * 100;
