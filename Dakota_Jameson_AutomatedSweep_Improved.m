%% Automated Voltage Sweep and Resistance Verification
%% Created by: Dakota Jameson
%% Date: 12/08/2024

% Reset instruments 
instrreset;

% Initialize VISA objects for Direct Multimeter and Power Supply
dmm = visa('keysight', 'USB0::0x2A8D::0x8E01::CN63470074::0::INSTR');
power_supply = visa('keysight', 'USB0::0x2A8D::0x8F01::CN63420410::0::INSTR');
fopen(dmm); % Opening the connection to the multimeter
fopen(power_supply);

% Preallocate arrays for voltage and current measurements
voltage_array = [];
current_array = [];

% Perform voltage sweep from 0V to 5V in 0.5V increments
for voltage_increment = 0:0.5:5

    % Set voltage on power supply and enable output
    fprintf(power_supply, sprintf('VOLTAGE %.1f', voltage_increment)); % Formatting data into a string variable
    fprintf(power_supply, 'VOLTAGE OUTPUT ON'); % Turning the power supply on
    
    % Measure voltage using DMM
    fprintf(dmm, 'MEASURE:VOLT:DC? AUTO,MAX'); % Asking the DMM what the measured voltage outputted is. We have the option to just ask the program to measure the voltage and not the max voltage by not including the AUTO,MAX part of the code line, however the DMM doesn't stay consistent when reading voltages. Therefore we want to establish some sort of constant when taking a measurement every iteration. In this case, the constant is taking the maximum measured voltage.
    measured_voltage = str2double(fscanf(dmm)); % Requesting the value from the DMM and storing it in the computer as a double
    voltage_array = [voltage_array, measured_voltage]; % Assigning the value to a voltage array. We are going to need this later for calculations.
    
    % Measure current using DMM
    fprintf(dmm, 'MEASURE:CURR? AUTO,MAX');
    measured_current = str2double(fscanf(dmm));
    current_array = [current_array, measured_current];
    
    % Display measurements in the command window
    fprintf('Voltage: %.2f Volts, Current: %.2f Amps\n', measured_voltage, measured_current);
end

% Calculate line of best fit for V-I data
coeffs = polyfit(voltage_array, current_array, 1); % Finding the coefficients of the line of best-fit for the recorded data
y_fit = polyval(coeffs, voltage_array); % Configuring the data to adjust to the x-axis

% Plot the measured data and best-fit line
figure(1);
grid on;
plot(voltage_array, current_array, 'ro', 'MarkerSize', 8); % Original data points
hold on;
plot(voltage_array, y_fit, 'b-', 'LineWidth', 1.5); % Best-fit line
title('Voltage vs. Current Characteristics');
xlabel('Measured Voltage (V)');
ylabel('Measured Current (A)');
legend({'Measured Data', 'Best-Fit Line'}, 'Location', 'northwest');

% Verify resistance and calculate percent error
expected_resistance = 1000; % Expected resistance in ohms (1 kΩ)
if numel(voltage_array) >= 5 && numel(current_array) >= 5
    
    % Calculate resistance using Ohm's Law (R = V / I)
    measured_resistance = voltage_array(5) / current_array(5); % The measured resistance can be calculated by reworking ohm's law to get R = V / I. We chose to extract the values of voltage at spot "5" in the array because that is when it theoretically is at it's highest. We decided to extract current at spot 5 as well because when voltage increases, so does current. Essentially meaning, when voltage is at its highest, so is the current
    percent_error = abs((measured_resistance - expected_resistance) / expected_resistance) * 100;
    
    % Display results
    fprintf('\nExpected Resistance: %.2f Ω\n', expected_resistance);
    fprintf('Measured Resistance: %.2f Ω\n', measured_resistance);
    fprintf('Percent Error: %.2f%%\n', percent_error);
    
    % Checking to see if the resistance falls within the 5% tolerance band
    % of the resistor
    if abs(measured_resistance - expected_resistance) <= 50 % Checking to see if the calculated resistance falls within the +- 50 ohms range
        disp('The resistance falls within the acceptable range.');
    else
        disp('The resistance does not fall within the acceptable range.');
    end
end

% Close connections and deleting the data from the memory of the computer
fclose(power_supply);
fclose(dmm);
delete(dmm);
delete(power_supply);
clear dmm;
clear power_supply;
