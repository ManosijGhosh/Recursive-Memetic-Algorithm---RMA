function [ranks]=SURank()
    x=importdata('dataUsedCurrent/Input.xlsx');
    tar=importdata('dataUsedCurrent/targetsF.xlsx');
    c=size(x,2);
    weights=zeros(1,c);
    for i=1:c
        weights(i)=computeSU(x(:,i),tar,'class');
        %fprintf('Feature - %d has weight - %f\n',i,weights(i));
    end
    [~,ranks]=sort(weights,'ascend');
    bar(weights);
    xlabel('Predictor rank');
    ylabel('Predictor importance weight');
    clear tar k;
    %{
    fp=fopen('dataUsedCurrent/ranksSU.txt','w');
    [~,c]=size(x);
    for i=1:c
        fprintf(fp,'%d\t',ranks(i));
        fprintf('%d\t',ranks(i));
    end
    fclose(fp);
    fprintf('\n');
    %}
end
function SU = computeSU(x,y,type)
    % Computes simmetric uncertainty between two variables
    %
    %
    % Copyright 2016 Riccardo Taormina (riccardo_taormina@sutd.edu.sg), 
    %      Gulsah Karakaya (gulsahkilickarakaya@gmail.com;), 
    %      Stefano Galelli (stefano_galelli@sutd.edu.sg),
    %      and Selin Damla Ahipasaoglu (ahipasaoglu@sutd.edu.sg;. 
    %
    % Please refer to README.txt for further information.

    nBins     = 10;
    quantType = 'equalwidth'; 

    % quantize variables
    bx = quantizeVariable(x,nBins,quantType);
    
    if strcmp(type,'class')
        count=max(y);   %class y
        temp=zeros(1,count);
        for i=1:count
            temp(i)=sum(y(:)==i);
        end
        by=temp;
    else
        y = quantizeVariable(y,nBins,quantType);   %for feature y, not class y
    end
    
    % compute entropies
    hX  = fEntropy(bx);
    hy  = fEntropy(by);
    hXy = jointEntropy(x, y);

    % compute mutual information
    MI = hX+hy-hXy;

    % compute symmetric uncertainty
    SU = 2*MI/(hX+hy);
end
function [val]=fEntropy(x)
    total=sum(x(1,:));
    val=0;
    for i=1:size(x,2)
        if x(i)~=0
            %fprintf('%f\t',((x(i)/total)*(log(x(i)/total))));
            val=val-((x(i)/total)*(log(x(i)/total)));
        end
    end
    %fprintf('\n');
end
function [val]=jointEntropy(x,y)
    sx=size(x,2);
    
    nBins=20;
    val=0;
    %for i=1:nBins
        for j=1:max(y)
            bx=quantizeVariable(x(y(:)==j,1),nBins,'equalwidth');
            val=val+(fEntropy(bx)*(sum(y(:)==j)/sx));
        end
    %end
end
function quantY = quantizeVariable(Y,nBins,type)
    % Unsupervised quantization of continuous variable
    %
    % Inputs:     Y     <- the variable to discretize
    %             nBins <- number of bins employed for quantization
    %             type  <- "equalfreq"  --> each bin has same same num. of observations
    %                   <- "equalwidth" --> each bin has same width
    %           
    %
    % Output:
    %            quantY <- the quantized variable (mean values of all observations in the bin)
    %
    %

    if strcmp(type,'equalfreq')
        % bins with same height
        temp1 = sort(Y);
        temp2 = ceil(linspace(1,numel(Y),nBins+1));  
        steps = temp1(temp2);    
        quantY = Y;
        for i = 1 : nBins
            if i == 1
                ixes = (Y>=steps(1)) .* (Y<=steps(2));
            else
                ixes = (Y>steps(i)) .* (Y<=steps(i+1));
            end
            quantY(logical(ixes)) = mean(Y(logical(ixes)));
        end
    elseif strcmp(type,'equalwidth')
        % bins with same width
        maxY = max(Y); minY = min(Y);    
        steps = linspace(minY,maxY,nBins-1);
        steps=[minY steps maxY];
        quantY = zeros(1,nBins);
        for i = 1 : nBins
            if i == 1
                ixes = (Y>=steps(1)) .* (Y<=steps(2));
            else
                ixes = (Y>steps(i)) .* (Y<=steps(i+1));
            end
            quantY(i) = sum((ixes));
        end
    else
        error('Type not recognized!!')
    end
end