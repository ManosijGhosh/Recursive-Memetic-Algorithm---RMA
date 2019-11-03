function []=crossValidationMLP()
rng('default');
x=importdata('dataUsedCurrent/Input.xlsx');
t=importdata('dataUsedCurrent/target.xlsx');
tar=importdata('dataUsedCurrent/targetsF.xlsx');
disp('imports done');
c=size(x,1);
%count1=sum(tar(:)==1);
%count0=sum(tar(:)==2);
selection=zeros(1,c);
fold=5;%input('Enter the number of folds - ');
l=max(tar);
%{
    prostate - [10 10 10 30 20];
    colon all 10
    AMLGSE2191 -

%}
h=[10 15 15 [20 5] 20];
for k=1:l
    count1=sum(tar(:)==k);
    samplesPerFold=int16(floor((count1/fold)));
    count=0;
    for j=1:fold
        count=0;
        for i=1:c
            if(tar(i)==k && selection(i)==0)
                selection(i)=j;
                count=count+1;
            end
            if(count==samplesPerFold)
                break;
            end
        end
    end
    j=1;
    for i=1:c
        if(selection(i)==0 && tar(i)==k)
            selection(i)=j;%sorts any extra into rest
            j=j+1;
        end
    end
end
%{
    samplesPerFold=int16(count0/fold);
    count=0;
    for j=1:fold
        count=0;
        for i=1:c
            if(tar(i)==2 && selection(i)==0)
                selection(i)=j;
                count=count+1;
            end
            if(count==samplesPerFold)
                break;
            end
        end
    end
    for i=1:c
        if(selection(i)==0 && tar(i)==2)
            selection(i)=int16(rand(1)*4)+1;%sorts any extra into rest
        end
    end
%}
for i=1:fold
    fprintf('Number of samples in fold - %d is %d   ',i,sum(selection(:)==i));
    fprintf('Number of 1s in fold is - %d\n',sum(tar(selection(:)==1)==1));
end

temp=load('dataUsedCurrent/results.mat');
list=temp.list;
temp=temp.population(1,:);
accuracy=zeros(1,fold);
x=x(:,list);
for i=1:fold
    fprintf('Fold - %d\n',i);
    chr=zeros(c,1);%0 training, 1 test
    for j=1:c
        if selection(j)==i
            chr(j,1)=1;
        end
    end
    for j=1:8
        per=nnetwork(x,t,chr,temp(1,:),h(i));
        if(per>accuracy(i))
            accuracy(i)=per;
        end
        if per==1
            break;
        end
    end
end
for i=1:fold
    fprintf('%f\t',accuracy(i));
end
fprintf('\n');
end
function [performance]=nnetwork(x,t,chr,chromosome,h)
if (sum(chromosome(:)==1)==0)
    performance=0;
else
    c=size(chromosome,2);
    
    target=t(chr(:)==0,:);
    
    input=x(chr(:)==0,chromosome(:)==1);
    %fprintf('Train set created\n');
    
    inputs = input';
    targets = target';
    
    
    hiddenLayerSize = h;
    
    net = patternnet(hiddenLayerSize);
    
    
    % Setup Division of Data for Training, Validation, Testing
    net.divideParam.trainRatio =85/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 0/100;
    
    % Train the Network
    %size(inputs)
    %size(targets)
    [net, ] = train(net,inputs,targets);
    
    clear targets target inputs input;
    % Test the Network
    %test set build
    target=t(chr(:)==1,:);
    input=x(chr(:)==1,chromosome(:)==1);
    inputs=input';targets=target';
    outputs = net(inputs);
    
    [c, ] = confusion(targets,outputs);
    fprintf('The number of features  : %d\n', sum(chromosome(:)==1));
    fprintf('Percentage Correct Classification   : %f%%\n', 100*(1-c));
    fprintf('Percentage Incorrect Classification : %f%%\n', 100*c);
    performance=1-c;%how much accuracy we get
    % View the Network
    %view(net);
    %}
end
end