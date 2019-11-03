function [per]=classify(x,t,chr,chromosome)
    ch = 3;
    if (ch==1)
        [per]=nnetwork(x,t,chr,chromosome);
    elseif (ch==2)
        [per]=svmClassifier(x,t,chr,chromosome);
    else
        [per]=knnClassifier(x,t,chr,chromosome);
    end
end