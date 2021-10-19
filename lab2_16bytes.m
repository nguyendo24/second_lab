load('C:\Users\Nhat\Documents\Learning\Matlab\assignment2\aes_power_data.mat')

bytes_recovered = zeros (1,16);
n_traces = 200; 
traces = traces (1:n_traces, :); 
traceSize = max(size(traces(1,:)));

segmentLength = 40000; 

% variables declaration
byteStart = 1;
byteEnd = 16;
keyCandidateStart = 0;
keyCandidateStop = 255;
solvedKey = zeros(1,byteEnd);

for BYTE=byteStart:byteEnd
    DoM(1,:) = zeros(1,segmentLength);
    Hypothesis = zeros(n_traces,256);
    
    for K = keyCandidateStart:keyCandidateStop                             

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
    
    
   [X,Y]=ind2sub(size(DoM), find(DoM==max(DoM(:))));
    
    solvedKey(1,BYTE) = X - 1;

end    
    

% fprintf('%x ', solvedKey);   
% solvedKey_hex = dec2hex(solvedKey);
% A = reshape(solvedKey_hex,128,16);
solvedKey_bi = dec2bin(solvedKey);
originalKey = [00, 11, 22, 33, 44, 55, 66, 77, 88, 99, 'AA', 'BB', 'CC', 'DD', 'EE', 'FF'];
originalKey_dec = [0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221, 238, 255];
originalKey_bi = dec2bin(originalKey_dec);

result = originalKey_bi - solvedKey_bi;
nonzeros = sum(result' ~=0);
s = sum(nonzeros(1,:));
accuracy = (128-s)/128 * 100;
