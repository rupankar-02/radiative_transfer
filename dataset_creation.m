% Define the ranges for each parameter
AOD = 0.2:0.2:2.0;    % AOD varies from 0.2 to 2.0 with an interval of 0.2
ALPHA = -0.5:0.5:2.0; % ALPHA varies from -0.5 to 2.0 with an interval of 0.5
SSA = 0.5:0.05:1.0;   % SSA varies from 0.5 to 1.0 with an interval of 0.05
ASY = 0.5:0.1:1.0;    % ASY varies from 0.5 to 1.0 with an interval of 0.1

% Initialize an empty array to hold the dataset
dataset = [];

% Nested for loops to generate all combinations of the parameters
for aod = AOD
    for alpha = ALPHA
        for ssa = SSA
            for asy = ASY
                % Append the current combination to the dataset
                dataset = [dataset; aod, alpha, ssa, asy];
            end
        end
    end
end

% Save the dataset to a .mat file
save('input_sbdart.mat', 'dataset', '-double');
