function [population,rank]=crossover(x,t,chr,population,id1,id2,rank)
    rng('shuffle');
    [r,c]=size(population);
    %if rand(1)>=probC %probC is flipping probability, higher it is more 
        point=int16(rand(1)*(c-1))+1;%genrates random integer btw [0,c]
        stop=int16(rand(1)*(c-1))+1;
        if stop < point
            temp=stop;
            stop=point;
            point=temp;
        end
        arr1=population(id1,:);
        arr2=population(id2,:);
        population2(1,1:point-1)=arr1(1,1:point-1);%copies part of arr1 into population2(1)
        population2(2,1:point-1)=arr2(1,1:point-1);
        for i = point:1:stop
            population2(1,i) = arr2(1,i);%crossover being done
            population2(2,i) = arr1(1,i);
        end
        population2(1,stop+1:c)=arr1(1,stop+1:c);%copies part of arr1 into ch1
        population2(2,stop+1:c)=arr2(1,stop+1:c);
        rch1=classify(x,t,chr,population2(1,:));
        rch2=classify(x,t,chr,population2(2,:));
        for i = r:-1:1
            if(chromosomecomparator(population(i,1:c),rank(i),population2(1,1:c),rch1)<0)
                fprintf('Replaced chromosome at %d in crossover with first\n',i);
                population(i,1:c)=population2(1,1:c);%substituition of chromose can be better
                rank(i)=rch1;
                break;
            end
        end
        for i = r:-1:1
            if(chromosomecomparator(population(i,1:c),rank(i),population2(2,1:c),rch2)<0)
                fprintf('Replaced chromosome at %d in crossover with second\n',i);
                population(i,1:c)=population2(2,1:c);
                rank(i)=rch2;
                break;
            end
        end
    %end
end