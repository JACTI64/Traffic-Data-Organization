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
