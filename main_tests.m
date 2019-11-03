function []=main_tests
ranks=zeros(1,7);
sizes=zeros(1,7);
values=zeros(1,7);
count=1;
for i=5:2.5:20
    [tempr,temp]=rma(int16(i));
    ranks(1,count)=tempr(1);
    values(1,count)=size(temp,1);
    sizes(1,count)=sum(temp(1,:));
    count=count+1;
end
count=count-1;
disp(values);
for i=1:count
    fprintf('%d\t',ranks(i));
end
fprintf('\n');
for i=1:count
    fprintf('%d\t',sizes(i));
end
fprintf('\n');
end
function [rank,population]=rma(value)
tic
x=importdata('dataUsedCurrent/Input.xlsx');
t=importdata('dataUsedCurrent/target.xlsx');
%size(t)
chr=importdata('dataUsedCurrent/selection.xlsx');
rng('shuffle');
%n=int16(input('Enter the number of chromosomes to work on :'));
n=value;
%mcross=int16(input('Enter the maximum number of crossovers to do :'));
mcross=int16(5);
probM=.3;

ftrank=importdata('dataUsedCurrent/franks.txt');

fprintf('imports done\n');
%%{
s=size(x,2);
population=datacreate(n,s);
fprintf('data created\n');
%[r,c]=size(population);
rank=zeros(1,n);
rankcs=zeros(1,n);
[population,rank]=chromosomeRank(x,t,chr,population,rank,0);
fprintf('Chromosomes ranked\n');
disp('Classification using SVM');
[~,aa]=size(x);
list=zeros(1,aa);
for i=1:aa
    list(i)=i;
end
clear aa;

fnum=2;acc=0.99;count=int16(1);
reccount=0;
if rank(1)>.96
    bound=rank(1);
else
    bound=.96;
end
%frank gives position where the features are whose rank is index
%ftrank(1)=position of feature of rank 1.
while ((sum(population(1,:)==1)>fnum || rank(1)<acc) && (count<=18))
    
    %improving the search space
    [~,c]=size(list);
    %c
    fprintf('bound is - %f\n',bound);
    if ((rank(1)>=bound && rank(2)>=bound && rank(3)>=bound && (count~=1) && (c>25)) || (reccount==0 && count==18))  %to one iteration is excuted before recreation
        fprintf('Bound - %f\n',bound);
        reccount=reccount+1;
        temp=(rank(1)+rank(2)+rank(3))/3;
        [population,rank,x,ftrank,list]=recreate(population,rank,x,t,chr,ftrank,n,list,reccount);
        count=1;
        if(reccount>8)
            if temp>.99
                bound=temp;
            else
                bound=.99;
            end
        elseif(reccount>6)
            if temp>.98
                bound=temp;
            else
                bound=.98;
            end
        elseif(reccount>3)
            if temp>.97
                bound=temp;
            else
                bound=.97;
            end
        end
    end
    %end of improvement
    if(count>10 && bound >= .95)
        bound=bound-.005;
    elseif(count>13 && bound >= .94)
        bound=bound-.005;
    end
    
    %local search
    fprintf('Local search done for the %d th time\n',count);
    [population,rank]=localsearch(x,t,chr,population,rank,ftrank);%local search on all chromosomes using relieff
    
    %crossover
    fprintf('\nCrossover done for %d th time\n',count);
    limit = randi(mcross,1)+1;%assmming at max m crossovers
    %(mod(rand(1,int16),(n))+1)
    
    for i=1:limit
        %cumulative sum for crossover
        rankcs(1:n)=rank(1:n);%copying the values of rank to rankcs
        for j= 2:n% size of weights = no. of features in popaulation=c
            rankcs(j)=rankcs(j)+rankcs(j-1);
        end
        maxcs=rankcs(n);
        for j= 1:n
            rankcs(j)=rankcs(j)/maxcs;
        end
        
        a=find(rankcs>rand(1),1,'first');
        b=find(rankcs>rand(1),1,'first');
        %roulette wheel ends
        
        [population,rank]=crossover(x,t,chr,population,a,b,rank); %Atleast 1 crossover
        %[population,rank]=crossover(x,t,population,randi(n,1),randi(n,1),rand(1),rank);
        clear a b j rankcs;
    end
    %crossover ends
    
    %mutation
    fprintf('\nMutation done for %d th time\n',count);
    for i = 1:n
        [population,rank]=mutation(x,t,chr,population,i,probM,rank);
    end
    %mutation over
    
    count=count+1;
    [population,rank]=chromosomeRank(x,t,chr,population,rank,1);
end
val=sum(population(1,:)==1);
fprintf('The least number of features is : %d\n',val);
fprintf('The best accuracy is : %d\n',rank(1));
str=strcat('ResultsComp/results_population_',num2str(n),'.mat');
save(str,'val','population','rank','list');
toc
end
function [population,rank,x,ftrank,list]=recreate(population,rank,x,t,chr,ftrank,n,list,count)
fprintf('\nPopulation recreated for - %d th time\n',count);
[r,c]=size(x);
newx=zeros(r,c);
newlist=zeros(c);
j=0;
%%{
%ensuring the top 10% population by relieff is always included
top=zeros(c);
for i = 1 : int16(c*.1)
    top(ftrank(i))=1;
end
%}
for i=1:c
    if( population(1,i)==1 || population(2,i)==1 || population(3,i)==1 || top(i)==1 )
        j=j+1;
        newx(1:r,j)=x(1:r,i);
        newlist(j)=list(i);
    end
end
x=newx(1:r,1:j);
list=newlist(1:j);
fprintf('New size is - %d\n',j);
population=datacreate(n,j);
[population,rank]=chromosomeRank(x,t,chr,population,rank,0);
tar=importdata('dataUsedCurrent/targetsF.xlsx');
k=10;tar=tar';
[ftrank,weights] = relieff(x,tar,k,'method','classification');%feature ranking
%new
%count=size(list);
str=strcat('Figure',num2str(count));
disp(str);
%new ends
%{
bar(weights(ftrank),'stacked');
xlabel('Predictor rank');
ylabel('Predictor importance weight');
title(str);
%add for correlation
clear newx r c j weights;
%}
end