% Create a VISA object
dmm = visa('keysight', 'USB0::0x2A8D::0x8E01::CN63470074::0::INSTR');

% Opening the connection to the DMM
fopen(dmm);

% Configure the measurement on the DMM
fprintf(dmm, 'MEASURE:VOLT:DC? AUTO,MAX');

% Storing DMM values as a double
volt = str2double(fscanf(dmm));

% Displaying the measured values
disp(['Measurement_Results:,' measurement]);

% Closing the connection
fclose(dmm);

% Clear the memory
delete(dmm);
clear dmm;
