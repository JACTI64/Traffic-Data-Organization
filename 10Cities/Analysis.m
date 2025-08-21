% Combined Processing and Data Preparation Script for MANOVA with Additional Analyses

try
    % Check if the processed data already exists in the workspace
    if ~exist('stationData_d2', 'var') || ~exist('stationNames', 'var')
        disp('Loading and processing data from files...');

        % Define days of the week
        dayOfWeekToName = containers.Map(1:7, {'Sunday', 'Monday', 'Tuesday', ...
            'Wednesday', 'Thursday', 'Friday', 'Saturday'});

        % List of .mat files to load
        files = {'station_1J0N31_ULYSSES.mat', 'station_2B24C5_COLBY.mat', ...
                 'station_3E6C43_MEAD.mat', 'station_4LGSU7_WAKEENEY.mat', ...
                 'station_4LLMV7_FORD.mat', 'station_6ULWT1_STJOHN.mat', ...
                 'station_7YG8T1_LYONS.mat', 'station_60G1E6_LARNED.mat', ...
                 'station_84T4V5_BELOIT.mat', 'station_ACC755_ARKCITY.mat'};

        % Initialize cell arrays to hold the data tables and file names
        stationData_d2 = {};
        stationNames = {};

        % Load and process each file
        for i = 1:length(files)
            % Load the .mat file
            data = load(files{i});

            % Extract the base file name (excluding the .mat extension)
            [~, fileName, ~] = fileparts(files{i});
            stationNames{end+1} = fileName;

            % Process yearly_station_data_d2
            if isfield(data, 'yearly_station_data_d2')
                T2 = array2table(data.yearly_station_data_d2, 'VariableNames', ...
                    {'Entry', 'Year', 'Month', 'DayofMonth', 'DayOfWeek', 'Hour', 'Direction', 'Density'});
                T2.DayName = arrayfun(@(d) dayOfWeekToName(d), T2.DayOfWeek, 'UniformOutput', false);
                stationData_d2{end+1} = T2;
            end

            disp(['Loaded and processed variables from ', files{i}]);
        end

        % Save the processed data to a .mat file
        save('processed_station_data.mat', 'stationData_d2', 'stationNames');
    else
        disp('Processed data already exists in the workspace.');
    end

    % Prepare data for MANOVA
    manovaMatrix = []; % Matrix for MANOVA
    groupLabels = []; % Vector for city names

    % Combine all datasets into one for MANOVA
    for i = 1:length(stationData_d2)
        data = stationData_d2{i};
        
        % Filter out weekends (only Monday to Friday)
        data = data(ismember(data.DayOfWeek, 2:6), :);  % Monday = 2, ..., Friday = 6

        % Extract unique days
        uniqueDates = unique(data(:, {'Year', 'Month', 'DayofMonth'}), 'rows');
        
        % Create matrix where each row is a day and columns are hours
        for j = 1:height(uniqueDates)
            dayData = data(data.Year == uniqueDates.Year(j) & ...
                           data.Month == uniqueDates.Month(j) & ...
                           data.DayofMonth == uniqueDates.DayofMonth(j), :);
                       
            % Ensure there are 24 hours of data for the day
            if height(dayData) == 24
                % Sort by hour to ensure correct order
                dayData = sortrows(dayData, 'Hour');
                
                % Append density values to the matrix
                manovaMatrix = [manovaMatrix; dayData.Density'];
                
                % Append city name to group labels
                groupLabels = [groupLabels; repmat({stationNames{i}}, 1, 1)];
            end
        end
    end

    % Ensure we have data for MANOVA
    if isempty(manovaMatrix)
        error('No data available for MANOVA.');
    end

    % Run MANOVA
    disp('Running MANOVA...');
    [d,~,stats] = manova1(manovaMatrix, groupLabels);

    % Display results
    disp('MANOVA results:');
    disp(stats);
    
    % Plot the Mahalanobis distances
    figure;
    manovacluster(stats);
    title('Mahalanobis distances between group means');

    % Canonical Discriminant Analysis (CDA)
    disp('Performing Canonical Discriminant Analysis...');
    [coeff,~,~,~,explained] = pca(manovaMatrix);
    cda = fitcdiscr(manovaMatrix, groupLabels);
    
    % Display canonical coefficients
    disp('Canonical Discriminant Coefficients:');
    disp(cda.Coeffs);

    % Display explained variance by each canonical variable
    disp('Explained Variance by Each Canonical Variable:');
    disp(explained);

    % Plot canonical discriminant functions
    [Y,score] = predict(cda, manovaMatrix);
    figure;
    gscatter(score(:,1), score(:,2), groupLabels);
    xlabel('Canonical Variable 1');
    ylabel('Canonical Variable 2');
    title('Canonical Discriminant Analysis');

    % Pairwise Comparisons
    disp('Performing Pairwise Comparisons...');
    numCities = length(stationNames);
    pValues = zeros(numCities);

    % Calculate pairwise MANOVA p-values
    for i = 1:numCities
        for j = i+1:numCities
            [~,p] = manova1(manovaMatrix(strcmp(groupLabels, stationNames{i}) | strcmp(groupLabels, stationNames{j}), :), ...
                            groupLabels(strcmp(groupLabels, stationNames{i}) | strcmp(groupLabels, stationNames{j})));
            pValues(i, j) = p;
            pValues(j, i) = p;
        end
    end

    disp('Pairwise MANOVA p-values:');
    disp(array2table(pValues, 'RowNames', stationNames, 'VariableNames', stationNames));

catch ME
    disp('An error occurred:');
    disp(ME.message);
    return;  % Stop execution
end

% cities = unique(groupLabels);
% city_traffic = [];
% 
% for i = 1:length(cities)
%     ind = find(strcmp(groupLabels,cities{i}));
%     mean_traffic = mean(manovaMatrix(ind,:));
%     city_traffic = [city_traffic;mean_traffic];
% end
% 
% 
% hold on
% for i = 1:length(cities)
%     plot(1:24,city_traffic(i,:),"r");
%     text(12,city_traffic(i,12),cities{i});
% end
% 
% hold off
