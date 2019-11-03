%creates a feature list & value of acuuracy of list out of 1(0-1)
function [data] = datacreate(n,size)
    %size=12533
    %n is the number of chromosomes we are working on
    %we take that it must have at least 50 features & at max 144 features
    rng('shuffle');
    max=int16(size);%number of features we have
    min=int16(size/6);%number of features we take minimum
    data=int16(zeros(n,max));
    for I=(int16(1)):n
        %x2=int16(abs(rand*(max-10000-min)))+min-5;%number of features we select at max will have 5 features less than maximum)
        x2=int16(abs(rand*(size/3-min)))+min;%number of features we select at max will have 5 features less than maximum)
        if x2==0
            x2=min;
        end
        count=0;
        for J=(int16(1)):x2
            a=int16((max-1)*rand)+1;
            while (data(int16(I),int16(a))==1)
                a=int16((max-1)*rand)+1;
            end
            %fprintf('Value of I - : %d%%\n', I);
            %fprintf('Value of a - : %d%%\n', a);
            data(int16(I),int16(a))=(int16(1));
            count=count+1;
        end
        %fprintf('number of features incorrect : %d \n', (count-x));
        %fprintf('number of features : %d \n', (count));
        clear x2
    end
    clear max min count
end