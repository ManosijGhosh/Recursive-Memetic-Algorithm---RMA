function [performance]=nnetwork(x,t,chr,chromosome)
    if (sum(chromosome(:)==1)==0)
        performance=0;
    else
        c=size(chromosome,2);
        
        target=t(chr(:)==0,:);
        
        input=x(chr(:)==0,chromosome(:)==1);
        %fprintf('Train set created\n');
        
        inputs = input';
        targets = target';
        
        if c>1000
            hiddenLayerSize = [70 30];
        elseif c>500
            hiddenLayerSize = 70;
        elseif c>100
            hiddenLayerSize = 50;
        elseif c>50
            hiddenLayerSize = 20;
        else
            hiddenLayerSize = 20;
        end
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