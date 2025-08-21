try
    % Define days of the week
    dayOfWeekToName = containers.Map(1:7, {'Sunday', 'Monday', 'Tuesday', ...
        'Wednesday', 'Thursday', 'Friday', 'Saturday'});
    weekdays = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'};

    % List of .mat files to load
    files = {'station_1J0N31_ULYSSES.mat', 'station_2B24C5_COLBY.mat', ...
             'station_3E6C43_MEAD.mat', 'station_4LGSU7_WAKEENEY.mat', ...
             'station_4LLMV7_FORD.mat', 'station_6ULWT1_STJOHN.mat', ...
             'station_7YG8T1_LYONS.mat', 'station_60G1E6_LARNED.mat', ...
             'station_84T4V5_BELOIT.mat', 'station_ACC755_ARKCITY.mat'};

    % Initialize structure to hold the data
    data_d1 = struct();

    % Load and process each file
    for i = 1:length(files)
        % Load the .mat file
        data = load(files{i});
        
        % Extract the base file name (excluding the .mat extension)
        [~, fileName, ~] = fileparts(files{i});
        
        % Process yearly_station_data_d1
        if isfield(data, 'yearly_station_data_d1')
            T1 = array2table(data.yearly_station_data_d1, 'VariableNames', ...
                {'Entry', 'Year', 'Month', 'DayofMonth', 'DayOfWeek', 'Hour', 'Direction', 'Density'});
            T1.DayName = arrayfun(@(d) dayOfWeekToName(d), T1.DayOfWeek, 'UniformOutput', false);
            data_d1.(fileName) = T1;  % Store table with city name
        end
        
        disp(['Loaded and processed variables from ', files{i}]);
    end

    % Check if data_d1 contains data
    if isempty(fieldnames(data_d1))
        error('No data loaded for d1.');
    end

    % Example: Compare data from two cities
    cityNames_d1 = fieldnames(data_d1);
    if length(cityNames_d1) < 2
        error('Not enough cities to compare for d1.');
    end

    % Randomly select two cities
    idx_d1 = randperm(length(cityNames_d1), 2);
    city1_d1 = cityNames_d1{idx_d1(1)};
    city2_d1 = cityNames_d1{idx_d1(2)};

    % Extract data for the selected cities
    data1_d1 = data_d1.(city1_d1);
    data2_d1 = data_d1.(city2_d1);

    % Display city data for debugging
    disp(['Data for city: ', city1_d1]);
    disp(head(data1_d1));  % Print first few rows of data for inspection

    disp(['Data for city: ', city2_d1]);
    disp(head(data2_d1));  % Print first few rows of data for inspection

    % Get valid weekday data for both cities
    [data1_randomWeekday_d1, randomWeekday1_d1] = getValidWeekdayData(data1_d1, weekdays);
    [data2_randomWeekday_d1, randomWeekday2_d1] = getValidWeekdayData(data2_d1, weekdays);

    % Prepare data for plotting
    figure;
    hold on;
    colors = lines(2);

    % Plot data for City 1
    plot(data1_randomWeekday_d1.Hour, data1_randomWeekday_d1.Density, 'DisplayName', sprintf('%s - %s', city1_d1, randomWeekday1_d_d), 'LineWidth', 2, 'Color', colors(1, :));

    % Plot data for City 2
    plot(data2_randomWeekday_d1.Hour, data2_randomWeekday_d1.Density, '--', 'DisplayName', sprintf('%s - %s', city2_d1, randomWeekday2_d_d), 'LineWidth', 2, 'Color', colors(2, :));

    % Customize plot
    xlabel('Hour of Day');
    ylabel('Density');
    title('Comparison of Traffic Density for a Random Weekday Across Two Cities');
    legend('show');
    grid on;
    hold off;

    % Display random weekdays selected for each city
    disp(['Random Weekday for City ', city1_d1, ': ', randomWeekday1_d1]);
    disp(['Random Weekday for City ', city2_d1, ': ', randomWeekday2_d1]);

    % Nested Function to find valid weekday data
    function [weekdayData, weekdayName] = getValidWeekdayData(data, weekdays)
        valid = false;
        while ~valid
            % Check available weekdays in data
            availableWeekdays = unique(data.DayName);
            
            % Select weekdays present in data only
            weekdaysPresent = intersect(weekdays, availableWeekdays);

            if isempty(weekdaysPresent)
                error('No valid weekdays found in the dataset.');
            end
            
            % Randomly select a weekday from available ones
            selectedWeekday = datasample(weekdaysPresent, 1, 'Replace', false);
            
            % Filter data for the selected weekday
            weekdayData = data(strcmp(data.DayName, selectedWeekday), :);
            
            % Check if the selected weekday has all 24 hours
            if height(weekdayData) == 24
                valid = true;
                weekdayName = selectedWeekday;
            else
                disp(['Weekday ', selectedWeekday, ' does not have all 24 hours.']);
            end
        end
    end

catch ME
    disp('An error occurred:');
    disp(ME.message);
    return;  % Stop execution
end
