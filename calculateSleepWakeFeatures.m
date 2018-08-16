function sleepWakeFeatures = calculateSleepWakeFeatures(epochLength, accDataX, accDataY, accDataZ)
%Function for calculating the features extracted from accrelerometer signals used in the sleep-wake detection algorithm
%
%Inputs :     epochLength           : The length of window that the features will be calculated during that window             
%             accDataX              : Acc raw data in X direction
%             accDataY              : Acc raw data in Y direction
%             accDataZ              : Acc raw data in Z direction
%Output :     sleepWakeFeatures     : A group of features extracted from Acc signals
%             
%
%Developed by: Bojan Gavrilovic Date: Aug 31 2017
%Modified by: Ensieh Hosseini  Date: Oct 19 2017

% Smooth and filter the data
smoothAccDataX = movingAverageFilter(accDataX,10,'Md');
smoothAccDataY = movingAverageFilter(accDataY,10,'Md');
smoothAccDataZ = movingAverageFilter(accDataZ,10,'Md');

dataLength = ceil(length(smoothAccDataX)/epochLength)*epochLength;
padValue = dataLength - numel(smoothAccDataX);
extraData = epochLength - padValue;

% Save the remainder data
remainderAccX = smoothAccDataX(end-extraData+1:end);
remainderAccY = smoothAccDataY(end-extraData+1:end);
remainderAccZ = smoothAccDataZ(end-extraData+1:end);

accDataXExtended = smoothAccDataX;
accDataYExtended = smoothAccDataY;
accDataZExtended = smoothAccDataZ;

accDataXExtended(dataLength) = 0;
accDataYExtended(dataLength) = 0;
accDataZExtended(dataLength) = 0;

windowedAccX = reshape(accDataXExtended,epochLength,[]);
windowedAccY = reshape(accDataYExtended,epochLength,[]);
windowedAccZ = reshape(accDataZExtended,epochLength,[]);

% Remove the last window because it is padded data
windowedAccX = windowedAccX(:,1:end-1);
windowedAccY = windowedAccY(:,1:end-1);
windowedAccZ = windowedAccZ(:,1:end-1);

deTrendAccX = detrend(windowedAccX,'constant');
deTrendAccY = detrend(windowedAccY,'constant');
deTrendAccZ = detrend(windowedAccZ,'constant');

% Calculate accelerometer features

% Calculate variance every 30 seconds
partialVarAccX = var(deTrendAccX);
partialVarAccY = var(deTrendAccY);
partialVarAccZ = var(deTrendAccZ);

% Calculate max every 30 seconds
partialMaxAccX = max(deTrendAccX);
partialMaxAccY = max(deTrendAccY);
partialMaxAccZ = max(deTrendAccZ);

deTrendAccX = reshape(deTrendAccX,[length(deTrendAccX)*length(deTrendAccX(1,:)),1]);
deTrendAccY = reshape(deTrendAccY,[length(deTrendAccY)*length(deTrendAccY(1,:)),1]);
deTrendAccZ = reshape(deTrendAccZ,[length(deTrendAccZ)*length(deTrendAccZ(1,:)),1]);

sleepWakeFeatures = struct('deTrendAccX',deTrendAccX, 'deTrendAccY', deTrendAccY, 'deTrendAccZ', deTrendAccZ,...
    'remainderAccX', remainderAccX, 'remainderAccY', remainderAccY, 'remainderAccZ', remainderAccZ,...
    'partialVarAccX', partialVarAccX, 'partialVarAccY', partialVarAccY, 'partialVarAccZ', partialVarAccZ,...
    'partialMaxAccX', partialMaxAccX, 'partialMaxAccY', partialMaxAccY, 'partialMaxAccZ', partialMaxAccZ);

end