function [population,rank]=chromosomeRank(x,t,chr,population,rank,flag)
    rng('shuffle');
    [r,c]=size(population);
    temp=zeros(c);
    if flag==0
        for i=1:r
            rank(i)=classify(x,t,chr,population(i,:));
            %rank(i)=rand(1);
        end
    end
    %{
    for i=1:r
        fprintf('R - %f\tnum- %d\n',rank(i),sum(population(i,1:c)==1));
    end
    fprintf('\n');
    %}
    for i =1:r
        for j =1:r-1
            if (rank(j)<rank(j+1) || (rank(j)==rank(j+1) && (sum(population(j,1:c)==1)>sum(population(j+1,1:c)==1))))    %in 1-r accuracy decreases
                val=rank(j);
                rank(j)=rank(j+1);
                rank(j+1)=val;
                temp(1:c)=population(j,1:c);
                population(j,1:c)=population(j+1,1:c);
                population(j+1,1:c)=temp(1:c);
            end
        end
        %{
        for j=1:r
            fprintf('R - %f\tnum- %d\n',rank(j),sum(population(j,1:c)==1));
        end
        fprintf('\n');
        %}
    end
    fprintf('\nPopulation now - \n');
    for i=1:r
        fprintf('R - %f\tnum- %d\n',rank(i),sum(population(i,1:c)==1));
    end
    fprintf('\n');
end
            