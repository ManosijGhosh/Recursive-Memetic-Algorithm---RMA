function [population,rank]=mutation(x,t,chr,population,id1,probM,rank)
    %index- index in population,probM-probability of mutation
    %higher value of probM higher is chance of mutation
    rng('shuffle');
    [~,c]=size(population);
    %flips the chromosomes(all the 1 & 0s based on probabilities
    member=zeros(1,c);
    if rand(1)<=probM%probM is flipping probability, higher it is more 
        %chances of flipping
        member=population(id1,:);%selects row index
        for j=1:1:c
            if rand(1)<=probM
                member(1,j)=1-member(1,j);%if 0 becomes 1, i becomes 0
            end
        end
    end
    if(sum(member(1,:))~=0)
        r=classify(x,t,chr,member);
        if(chromosomecomparator(population(id1,:),rank(id1),member(1:c),r)<0)
            fprintf('Replaced chromosome at %d in mutation\n',id1);
            population(id1,:)=member(1,1:c);
            rank(id1)=r;
        end
    end
end
