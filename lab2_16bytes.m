load('C:\Users\Nhat\Documents\Learning\Matlab\assignment2\aes_power_data.mat')

bytes_recovered = zeros (1,16);
n_traces = 200; 
traces = traces (1:n_traces, :); 
traceSize = max(size(traces(1,:)));

segmentLength = 40000; % for the beginning the segmentLength = traceSize

% variables declaration
byteStart = 1;
byteEnd = 16;
keyCandidateStart = 0;
keyCandidateStop = 255;
solvedKey = zeros(1,byteEnd);

% Create the hypothesis matrix 
% (dimensions: rows = numberOfTraces, columns = 256). 
% The number 256 represents all possible bytes (e.g., 0x00..0xFF)
    

for BYTE=byteStart:byteEnd
    DoM(1,:) = zeros(1,segmentLength);
    Hypothesis = zeros(n_traces,256);
    
    for K = keyCandidateStart:keyCandidateStop                     
        
%         Hypothesis(1:length(n_traces),K+1)=bitxor(plain_text(1:length(n_traces),BYTE),K);
%         Hypothesis(1:length(n_traces),K+1)=sbox(Hypothesis(1:length(n_traces),K+1)+1);

        Hypothesis(:,K+1)=bitxor(plain_text(:,BYTE),K);
        Hypothesis(:,K+1)=sbox(Hypothesis(:,K+1)+1);
        
        group1 = zeros(1,segmentLength);
        group2 = zeros(1,segmentLength);
     

        nbTracesG1 = 0;
        nbTracesG2 = 0;
        
        
        for L = 1:n_traces
            
            firstByte = bitget(Hypothesis(L,K+1),1);
            
            if firstByte == 1
                
                group1(1,:) = group1(1,:) + traces(L,:);
                nbTracesG1 = nbTracesG1 + 1;
            else
                group2(1,:) = group2(1,:) + traces(L,:);
                nbTracesG2 = nbTracesG2 + 1;
            end
        end
        
        group1(1,:) = group1(1,:) / nbTracesG1;
        group2(1,:) = group2(1,:) / nbTracesG2;
        
        DoM(K+1,:) = abs(group1(1,:)-group2(1,:));
    end
    
    
    [ligne,colonne]=ind2sub(size(DoM), find(DoM==max(DoM(:))));
    
    solvedKey(1,BYTE) = ligne - 1;

    fprintf('%x ', solvedKey);
   
    
    
%     figure(3);.m
%     plot(groupFin(1,:));
%     title('DPA !');
end    
    

% solvedKey_hex = dec2hex(solvedKey);
% A = reshape(solvedKey_hex,128,16);