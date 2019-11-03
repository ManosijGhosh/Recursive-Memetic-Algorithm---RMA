function []=rankingComparater()
    rankS=importdata('dataUsedCurrent/ranksSU.txt');
    rankR=importdata('dataUsedCurrent/franks.txt');
    c=size(rankS,2);
    temp1=zeros(1,c);
    temp2=zeros(1,c);
    
    for i = 1:c
        temp1(rankS(i))=i;
        temp2(rankR(i))=i;
    end
    for i = 1:c
        fprintf('%d\t',temp1(i));
    end
    fprintf('\n');
    for i = 1:c
        fprintf('%d\t',temp2(i));
    end
    fprintf('\n');
end