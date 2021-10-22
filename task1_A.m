load 'aes_power_data.mat';

bytes_recovered = zeros (1,16);
n_traces = 200; 
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

BYTE = 16;

    % Create the hypothesis matrix (dimensions: 
    % rows = n_traces, columns = 256). 
    % The number 256 represents all possible bytes (e.g., 0x00..0xFF)    
    DoM(1,:) = zeros(1,traceSize);
    Hypothesis = zeros(n_traces,256);

    for K = keyCandidateStart:keyCandidateStop          
        
        
        % Calculate the hypothesis
        Hypothesis(:,K+1)=bitxor(plain_text(1:n_traces,BYTE),K);
        Hypothesis(:,K+1)=sbox(Hypothesis(:,K+1)+1);
        
        group1 = zeros(1,segmentLength);
        group2 = zeros(1,segmentLength);
        
        % separate traces in two groups
        nbTracesG1 = 0;
        nbTracesG2 = 0;
           
        %for all traces put into one or other group based on 
        % predicted Least Significant Bit (LSB)
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

   
% convert solved key to hexadecimal 
solvedKey_hex = dec2hex(solvedKey);

% Make the plots
OFFSSET= 192 ; % for N=64, 0 , 64. 128, 192
N=4; % for an NxN plot
for i = 1:N
    for j = 1:N
        [X,Y] = find(DoM==max(DoM((i-1)*N+j+OFFSSET, :)));
        index = max(Y(:));
        subplot(N,N,(i-1)*N+j)
        plot(DoM ((i-1)*N+j+OFFSSET, :), '--o', 'MarkerIndices',index,'MarkerFaceColor','yellow')
        
    end
end
