function [ cost, grad, trainingError, confusion ] = ComputeFullCostAndGrad( theta, decoder, data, hyperParams )
%function [ cost, grad ] = ComputeFullCostAndGrad( theta, decoder, data, hyperParams )
%   Compute cost and gradient over a full dataset for some parameters.

N = length(data);

argout = nargout;
if nargout > 3
    confusions = zeros(N, 2);
end

accumulatedCost = 0;
accumulatedSuccess = 0;
if nargout > 1
    accumulatedGrad = zeros(length(theta), 1);
end

% Parallelize
if matlabpool('size') == 0 % checking to see if my pool is already open
    matlabpool;
end

if nargout > 2
    parfor i = 1:N
        [localCost, localGrad, localPred] = ...
            ComputeCostAndGrad(theta, decoder, data(i), hyperParams);
        accumulatedCost = accumulatedCost + localCost;
        accumulatedGrad = accumulatedGrad + localGrad;
        
        localCorrect = localPred == data(i).relation;
        if ~localCorrect
            disp(['for: ', data(i).leftTree.getText, ' - ', ...
            	  data(i).rightTree.getText, ' h:' , ...
                  num2str(data(i).relation), ' t: ', num2str(localPred)]);
        end
        
        if argout > 3
            confusions(i,:) = [localPred, data(i).relation]
        end
             
        accumulatedSuccess = accumulatedSuccess + localCorrect;
    end
    
    if nargout > 3
        confusion = zeros(hyperParams.numRelations);
        for i = 1:N
           confusion(confusions(i,1), confusions(i,2)) = ...
               confusion(confusions(i,1), confusions(i,2)) + 1;
        end
    end
elseif nargout > 1
    parfor i = 1:N
        [localCost, localGrad] = ...
            ComputeCostAndGrad(theta, decoder, data(i), hyperParams);
        accumulatedCost = accumulatedCost + localCost;
        accumulatedGrad = accumulatedGrad + localGrad;
    end
else
    parfor i = 1:N
        localCost = ...
            ComputeCostAndGrad(theta, decoder, data(i), hyperParams);
        accumulatedCost = accumulatedCost + localCost;
    end
end

cost = (1/length(data) * accumulatedCost);
cost = cost + (hyperParams.lambda/2 * sum(theta.^2));

if nargout > 1
    grad = (1/length(data) * accumulatedGrad);
    grad = grad + (hyperParams.lambda * theta);
    if nargout > 2
        trainingError = 1 - (accumulatedSuccess / N);
    end
end

end