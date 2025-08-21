% Process yearly_station_data_d2
% Assuming yearly_station_data_d2 is your double array already loaded
T2 = array2table(yearly_station_data_d2);

% Rename the columns
T2.Properties.VariableNames = {'Entry', 'Year', 'Month', 'DayofMonth', 'DayofWeek', 'Hour', 'Direction', 'Density'};

% Save the new table as CityDATA
CityDATA = T2;

% Process yearly_station_data_d1
% Assuming yearly_station_data_d1 is your double array already loaded
T1 = array2table(yearly_station_data_d1);

% Rename the columns
T1.Properties.VariableNames = {'Entry', 'Year', 'Month', 'DayofMonth', 'DayofWeek', 'Hour', 'Direction', 'Density'};

% Save the new table as CityDATA_D1
CityDATA_D1 = T1;
