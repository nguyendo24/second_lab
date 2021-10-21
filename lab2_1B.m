
% Load plaintext, ciphertext, traces, and sbox
load 'aes_power_data.mat';

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
currentKeyByte = 16;

% Create the hypothesis matrix 
% (dimensions: rows = numberOfTraces, columns = 256). 
% The number 256 represents all possible bytes (e.g., 0x00..0xFF)


% groupFin(1,:) = zeros(1,segmentLength);
DoM(1,:) = zeros(1,segmentLength);
Hypothesis = zeros(n_traces,256);

for K = keyCandidateStart:keyCandidateStop    
        
        
        Hypothesis(1:length(n_traces),K+1)=bitxor(plain_text(1:length(n_traces),currentKeyByte),K);
        Hypothesis(1:length(n_traces),K+1)=sbox(Hypothesis(1:length(n_traces),K+1)+1);
        
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

        groupDifference = abs(group1(1,:)-group2(1,:));
        DoM(K+1,:) = groupDifference;
%         maxDifference = max(groupDifference);
        
%         groupFin(K+1,:) = abs(group1(1,:)-group2(1,:));
end
    

[traceDifferenceWithLargestValueX, traceDifferenceWithLargestValueY] = find(DoM==max(DoM(:)));
% solvedKey = traceDifferenceWithLargestValueX - 1;

solvedKey(1:length(traceDifferenceWithLargestValueX),currentKeyByte) = traceDifferenceWithLargestValueX - 1;
   
%A = ones(segmentLength,128);
%B = DoM*A*solvedKey;
%C = B.*solvedKey;
%B = solvedKey(:,currentKeyByte);
%[m,n] = size(B);
%fprintf('%d %d\n', m, n);
%C = transpose(B);
%D = DoM.*A.*C;

%plot(B)

%max_y_val = max(traceDifferenceWithLargestValueY (:));

idxmin = max(traceDifferenceWithLargestValueY (:));


%% Sample code to make plots 
OFFSSET= 192 ; % for N=64, 0 , 64. 128, 192
N=8; % for an NxN plot
for i = 1:N
    for j  =1:N
        subplot(N,N,(i-1)*N+j)
        %plot(DoM ((i-1)*N+j+OFFSSET, :) )
        plot(DoM ((i-1)*N+j+OFFSSET, :), '-p', 'MarkerIndices',idxmin,'MarkerFaceColor','red' )
        
    end
end


hexStr = dec2hex(solvedKey);
fprintf('%x ', solvedKey);
fprintf('\n');
fprintf('%x ', hexStr);