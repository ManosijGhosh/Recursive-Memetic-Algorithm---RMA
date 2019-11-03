function []=crossValidationSVM()
    rng('default');
    x=importdata('dataUsedCurrent/Input.xlsx');
    t=importdata('dataUsedCurrent/target.xlsx');
    tar=importdata('dataUsedCurrent/targetsF.xlsx');
    disp('imports done');
    c=size(x,1);
    selection=zeros(1,c);
    fold=5;%input('Enter the number of folds - ');
    l=max(tar);
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
    %selection
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
        for j=1:1
            per=svmClassify(x,t,chr,temp(1,:));
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

function [performance]=svmClassify(x,t,chr,chromosome)
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
        
        if max(label)==2
            svmModel=fitcsvm(x,label,'KernelFunction','polynomial','Standardize',true,'ClassNames',[1 2]);
        else
            class=zeros(1,max(label));
            for i=1:max(label)
                class(i)=i;
            end
            temp = templateSVM('Standardize',1,'KernelFunction','polynomial');
            svmModel = fitcecoc(x,label,'Learners',temp,'FitPosterior',1,'ClassNames',class,'Coding','onevsall');
        end
        [label,~] = predict(svmModel,x2);
        %svmModel=svmtrain(x,label);
        %label=svmclassify(svmModel,x2);
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