%% Completed by Dakota Jameson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Resetting the instruments
instrreset;

dmm = visa('keysight', 'USB0::0x2A8D::0x8E01::CN63470074::0::INSTR'); % Creating a VISA object
fopen(dmm); % Opening the connection to the DMM

%% Code for Voltage Sweep from 0.5 to 5 Volts

power_supply = visa('keysight', 'USB0::0x2A8D::0x8F01::CN63420410::0::INSTR'); % Since the connection is needed to both the power supply and the DMM for automated voltage control, we need to repeat the steps we did with the DMM to connect to the power supply
fopen(power_supply); % Opening the connection to the power supply

int i; % Loop control variable
int voltage_array; % Voltage array created to store the values of the voltages every iteration
int current_array; % Current array with the same function as the voltage array
voltage_array = []; % Declaring the variable as an array
current_array = [];
int counter; % Counter variable used in the array to store elements in different spots in the array so the values aren't constantly overwriting each other

for i = 0:0.5:5 % Loop variable starts at 0, increments by 0.5, and stops at 5. We can use this format in MATLAB to avoid counter variables and other things that aren't necessary
    for counter = 0:0.5:5
        fprintf(power_supply, sprintf('VOLTAGE %f', i)); % Setting our initial voltage
        fprintf(power_supply, 'VOLTAGE OUTPUT ON'); % Turning on the connection between the output of the power supply and the DMM
        fprintf(dmm, 'MEASURE:VOLT:DC? AUTO,MAX'); % Asking the DMM what the measured voltage outputted is. We have the option to just ask the program to measure the voltage and not the max voltage by not including the AUTO,MAX part of the code line, however the DMM doesn't stay consistent when reading voltages. Therefore we want to establish some sort of constant when taking a measurement every iteration. In this case, the constant is taking the maximum measured voltage.
        voltage_value = str2double(fscanf(dmm)); % Requesting the value from the DMM and storing it in the computer as a double
        voltage_array = [counter, voltage_value]; % Assigning the value to a voltage array. We are going to need this later for calculations. 
        fprintf(dmm, 'MEASURE:CURR? AUTO,MAX'); % Asking the DMM what the measure current read is. Again, we will stay consistent, only asking for the max value observed for that voltage value
        current_value = str2double(fscanf(dmm)); % Requesting the value of the current and storing it as a double like we did with the voltage
        current_array = [counter, current_value]; % Assigning the value to a current array.
        disp(['Measurement_Result:,' voltage_value]); % displaying the value of the voltage to the command window
        disp(['Measurement_Result:,' current_value]); % displaying the value of the associated current to the command window

    end

end % Ending the loop

% Finding the coefficients of the line of best fit

coeffs = polyfit(voltage_array, current_value, 1); % Finding the coefficients 
y_fit = polyval(coeffs, voltage_value); % Configuring the data to match with the x axis

% 11.4: Plotting the voltage and current found with a line of best fit
figure(1)
grid on % applying a grid to the graph
plot(voltage_array, current_value, 'ro') % plotting the original data points
hold on
plot(voltage_value, y_fit, "c-") % plotting the line of best fit on the graph along with the data points
title('Measured Voltage (V) & Measured Current (A)')
xlabel('Measured Voltage (V)')
ylabel('Measured Current (A)')

% 11.5 Comparing the values of resistance the calculating the percent error

expected_resistance = 1000; % The value of the expected resistance is 1000 ohms
measured_resistance = voltage_array(5) / current_array(5); % The measured resistance can be calculated by reworking ohm's law to get R = V / I. We chose to extract the values of voltage at spot "5" in the array because that is when it theoretically is at its highest. We decided to extract current at spot 5 as well because when voltage increases, so does the current

percent_error = ((measured_resistance - expected_resistance) / (expected_resistance)) * 100; % Percent error formula

% Closing the connection between the computer, DMM, and power supply

fclose(power_supply); % Closing the connection to the power supply
fclose(dmm); % Closing the connection to the DMM

% 11.6 Measurements in range

if measured_resistance <= 1050 && measured_resistance >= 950 % 1050 ohms is our ceiling and 950 ohms is our floor because the resistor has a tolerance of +-5%, which is 50 ohms 
    fprintf('The resistance falls within range')
else
    fprintf('The resistance does not fall within range')
end

% Deleting the dmm & power supply from the memory of the computer

delete(dmm);
delete(power_supply);
clear dmm;
clear power_supply;
