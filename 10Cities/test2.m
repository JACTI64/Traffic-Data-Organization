% Combined Processing and Plotting Script for Specific Comparisons with Same Random Day

try
    % Check if the processed data already exists in the workspace
    if ~exist('stationData_d2', 'var') || ~exist('stationNames', 'var')
        disp('Loading and processing data from files...');

        % Define days of the week
        dayOfWeekToName = containers.Map(1:7, {'Sunday', 'Monday', 'Tuesday', ...
            'Wednesday', 'Thursday', 'Friday', 'Saturday'});

        % List of .mat files to load
        files = {'station_4LGSU7_WAKEENEY.mat', 'station_ACC755_ARKCITY.mat'};

        % Initialize cell arrays to hold the data tables and file names
        stationData_d2 = {};
        stationNames = {};

        % Load and process each file
        for i = 1:length(files)
            filePath = files{i};
            if exist(filePath, 'file')
                disp(['Loading file: ', filePath]);
                data = load(filePath);

                % Extract the base file name (excluding the .mat extension)
                [~, fileName, ~] = fileparts(filePath);
                stationNames{end+1} = fileName;

                % Process yearly_station_data_d2
                if isfield(data, 'yearly_station_data_d2')
                    T2 = array2table(data.yearly_station_data_d2, 'VariableNames', ...
                        {'Entry', 'Year', 'Month', 'DayofMonth', 'DayOfWeek', 'Hour', 'Direction', 'Density'});
                    T2.DayName = arrayfun(@(d) dayOfWeekToName(d), T2.DayOfWeek, 'UniformOutput', false);
                    stationData_d2{end+1} = T2;
                else
                    disp(['Variable yearly_station_data_d2 not found in ', filePath]);
                end

                disp(['Loaded and processed variables from ', filePath]);
            else
                disp(['File does not exist: ', filePath]);
            end
        end

        % Save the processed data to a .mat file
        save('processed_station_data.mat', 'stationData_d2', 'stationNames');
    else
        disp('Processed data already exists in the workspace.');
    end

    % Define the datasets to compare
    datasetNames = {'4LGSU7_WAKEENEY', 'ACC755_ARKCITY'};
    datasetIndices = find(ismember(stationNames, datasetNames));

    % Debugging: Display dataset names and indices
    disp('Loaded Dataset Names:');
    disp(stationNames);
    disp('Requested Dataset Names:');
    disp(datasetNames);
    disp('Dataset Indices:');
    disp(datasetIndices);

    if length(datasetIndices) ~= 2
        error('One or both specified datasets were not found.');
    end

    % Extract datasets
    data1 = stationData_d2{datasetIndices(1)};
    data2 = stationData_d2{datasetIndices(2)};

    % Filter out weekends (only Monday to Friday)
    data1 = data1(ismember(data1.DayOfWeek, 2:6), :);  % Monday = 2, ..., Friday = 6
    data2 = data2(ismember(data2.DayOfWeek, 2:6), :);

    % Randomly select a date from the first dataset
    uniqueDates1 = unique(data1(:, {'Year', 'Month', 'DayofMonth'}), 'rows');
    if isempty(uniqueDates1)
        error('Not enough unique dates in the dataset to select randomly.');
    end

    % Select a random date from the first dataset
    randomDate = uniqueDates1(randi(size(uniqueDates1, 1)), :);

    % Extract data for the selected random date from both datasets
    data1_randomDate = data1(data1.Year == randomDate.Year & ...
                             data1.Month == randomDate.Month & ...
                             data1.DayofMonth == randomDate.DayofMonth, :);

    data2_randomDate = data2(data2.Year == randomDate.Year & ...
                             data2.Month == randomDate.Month & ...
                             data2.DayofMonth == randomDate.DayofMonth, :);

    % Prepare data for plotting
    figure;
    hold on;
    colors = lines(2);

    % Plot data for Dataset 1
    plot(data1_randomDate.Hour, data1_randomDate.Density, 'DisplayName', sprintf('%s - %d/%d/%d', stationNames{datasetIndices(1)}, randomDate.Month, randomDate.DayofMonth, randomDate.Year), 'LineWidth', 2, 'Color', colors(1, :));

    % Plot data for Dataset 2
    plot(data2_randomDate.Hour, data2_randomDate.Density, '--', 'DisplayName', sprintf('%s - %d/%d/%d', stationNames{datasetIndices(2)}, randomDate.Month, randomDate.DayofMonth, randomDate.Year), 'LineWidth', 2, 'Color', colors(2, :));

    % Customize plot
    xlabel('Hour of Day');
    ylabel('Density');
    title('Comparison of Traffic Density on Same Random Weekday (Mon-Fri) - Wakeeney vs ArkCity');
    legend('show');
    grid on;
    hold off;

    % Display random date selected for both datasets
    disp('Comparison:');
    disp(['Random Date for both datasets:']);
    disp(randomDate);

catch ME
    disp('An error occurred:');
    disp(ME.message);
    return;  % Stop execution
end

