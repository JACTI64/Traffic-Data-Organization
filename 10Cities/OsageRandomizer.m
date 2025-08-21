% Combined Processing and Plotting Script with Multiple Comparisons

try
    % Check if the processed data already exists in the workspace
    if ~exist('stationData_d2', 'var') || ~exist('stationNames', 'var')
        disp('Loading and processing data from files...');

        % Define days of the week
        dayOfWeekToName = containers.Map(1:7, {'Sunday', 'Monday', 'Tuesday', ...
            'Wednesday', 'Thursday', 'Friday', 'Saturday'});

        % List of .mat files to load
        files = {'station_1J0N31_ULYSSES.mat', 'station_ACC755_ARKCITY.mat'};

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

    % Number of comparisons to make
    numComparisons = 3;

    % Randomly select pairs of datasets for comparison
    numFiles = length(stationData_d2);
    if numFiles < 2
        error('Not enough datasets to compare.');
    end

    for comparisonIdx = 1:numComparisons
        idx = randperm(numFiles, 2);
        dataSet1 = idx(1);
        dataSet2 = idx(2);

        % Load the datasets from the cell arrays
        data1 = stationData_d2{dataSet1};
        data2 = stationData_d2{dataSet2};

        % Filter out weekends (only Monday to Friday)
        data1 = data1(ismember(data1.DayOfWeek, 2:6), :);  % Monday = 2, ..., Friday = 6
        data2 = data2(ismember(data2.DayOfWeek, 2:6), :);

        % Randomly select 1 date from each dataset
        uniqueDates1 = unique(data1(:, {'Year', 'Month', 'DayofMonth'}), 'rows');
        uniqueDates2 = unique(data2(:, {'Year', 'Month', 'DayofMonth'}), 'rows');

        if isempty(uniqueDates1) || isempty(uniqueDates2)
            error('Not enough unique dates in the dataset to select randomly.');
        end

        randomDate1 = uniqueDates1(randi(size(uniqueDates1, 1)), :);
        randomDate2 = uniqueDates2(randi(size(uniqueDates2, 1)), :);

        % Extract data for the selected random date
        data1_randomDate = data1(data1.Year == randomDate1.Year & ...
                                 data1.Month == randomDate1.Month & ...
                                 data1.DayofMonth == randomDate1.DayofMonth, :);

        data2_randomDate = data2(data2.Year == randomDate2.Year & ...
                                 data2.Month == randomDate2.Month & ...
                                 data2.DayofMonth == randomDate2.DayofMonth, :);

        % Prepare data for plotting
        figure;
        hold on;
        colors = lines(2);

        % Plot data for Dataset 1
        plot(data1_randomDate.Hour, data1_randomDate.Density, 'DisplayName', sprintf('%s - %d/%d/%d', stationNames{dataSet1}, randomDate1.Month, randomDate1.DayofMonth, randomDate1.Year), 'LineWidth', 2, 'Color', colors(1, :));

        % Plot data for Dataset 2
        plot(data2_randomDate.Hour, data2_randomDate.Density, '--', 'DisplayName', sprintf('%s - %d/%d/%d', stationNames{dataSet2}, randomDate2.Month, randomDate2.DayofMonth, randomDate2.Year), 'LineWidth', 2, 'Color', colors(2, :));

        % Customize plot
        xlabel('Hour of Day');
        ylabel('Density');
        title(sprintf('Comparison of Traffic Density on Random Weekdays (Mon-Fri) - Comparison %d', comparisonIdx));
        legend('show');
        grid on;
        hold off;

        % Display random dates selected for each dataset
        disp(['Comparison ', num2str(comparisonIdx), ':']);
        disp(['Random Date for ', stationNames{dataSet1}, ':']);
        disp(randomDate1);
        disp(['Random Date for ', stationNames{dataSet2}, ':']);
        disp(randomDate2);
    end

catch ME
    disp('An error occurred:');
    disp(ME.message);
    return;  % Stop execution
end
