function []=crossValidationKNN()
    rng('default');
    x=importdata('dataUsedCurrent/Input.xlsx');
    t=importdata('dataUsedCurrent/target.xlsx');
    tar=importdata('dataUsedCurrent/targetsF.xlsx');
    disp('imports done');
    c=size(x,1);
    l=max(tar);
    
    selection=zeros(1,c);
    fold=5;%input('Enter the number of folds - ');
    
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
        for j=1:10
            per=knnClassify(x,t,chr,temp(1,:),j);
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
function [performance]=knnClassify(x,t,chr,chromosome,h)
    if(sum(chromosome(1,:)==1)~=0)
        x2=x(chr(:)==1,chromosome(:)==1);
        t2=t(chr(:)==1,:);
        x=x(chr(:)==0,chromosome(:)==1);
        t=t(chr(:)==0,:);
        s=size(t,1);
        label=zeros(1,s);
        for i=1:s
            label(1,i)=find(t(i,:),1);
        end

        knnModel=fitcknn(x,label,'NumNeighbors',h,'Standardize',1);
        %knnModel=fitcknn(x,label);
        [label,score] = predict(knnModel,x2);
        %label
        
        s=size(t2,1);
        lab=zeros(s,1);
        for i=1:s
            lab(i,1)=find(t2(i,:),1);
        end
        %[c,~]=confusion(t2,label);
        %%{
        %size(lab)
        %size(label)
        c = sum(lab ~= label)/s; % mis-classification rate
        %conMat = confusionmat(Y(P.test),C) % the confusion matrix
        %}
        performance=1-c;
        fprintf('Number of features - %d\n',sum(chromosome(1,:)==1));
        fprintf('The correct classification is %f\n',(100*performance));
    else
        performance=0;
    end
end