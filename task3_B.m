load('C:\Users\Nhat\Documents\Learning\Matlab\assignment2\aes_power_data.mat')

bytes_recovered = zeros (1,16);

numberOfTraces = 20; 
traces = traces (1:numberOfTraces, :); 
traceSize = 40000;

byteStart = 1;
byteEnd = 16;
keyCandidateStart = 0;
keyCandidateStop = 255;
result = zeros(1,16);

for BYTE=byteStart:byteEnd

    
    DoM(1,:) = zeros(1,traceSize);
    powerHypothesis = zeros(numberOfTraces,256);
    
    for K = keyCandidateStart:keyCandidateStop                             
        
        
        powerHypothesis(:,K+1)=bitxor(plain_text(1:numberOfTraces,BYTE),K);
        powerHypothesis(:,K+1)=sbox(powerHypothesis(:,K+1)+1);
        
        group1 = zeros(1,traceSize);
        group2 = zeros(1,traceSize);
        
        
        numberOfTracesInGroup1  = 0;
        numberOfTracesInGroup2  = 0;
           
        
        
        for L = 1:numberOfTraces
            
        
            firstByte = bitget(powerHypothesis(L,K+1),1);
            
            if firstByte == 1
                
                group1(1,:) = group1(1,:) + traces(L,:);
                numberOfTracesInGroup1 = numberOfTracesInGroup1 + 1;
            else
                group2(1,:) = group2(1,:) + traces(L,:);
                numberOfTracesInGroup2 = numberOfTracesInGroup2 + 1;
            end
        end
        
        
        group1(1,:) = group1(1,:) / numberOfTracesInGroup1; 
        group2(1,:) = group2(1,:) / numberOfTracesInGroup2; 
        
        DoM(K+1,:) = abs(group1(1,:)-group2(1,:)); 
    end
    

   [traceDifferenceWithLargestValueX,traceDifferenceWithLargestValueY]=ind2sub(size(DoM), find(DoM==max(DoM(:))));
    

   result(1,BYTE) = traceDifferenceWithLargestValueX - 1;

end    
    

resultKeyInHeximal = dec2hex(result);


resultKeyInBinary = dec2bin(result);


correctKeyHeximal = [00, 11, 22, 33, 44, 55, 66, 77, 88, 99, 'AA', 'BB', 'CC', 'DD', 'EE', 'FF'];


correctKeyDecimal = [0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221, 238, 255];


correctKeyBinary = dec2bin(correctKeyDecimal);


A = correctKeyBinary - resultKeyInBinary;

sum_nnz = sum(sum(A(:,:)~=0));

accuracy = (128-sum_nnz)/128 * 100;
