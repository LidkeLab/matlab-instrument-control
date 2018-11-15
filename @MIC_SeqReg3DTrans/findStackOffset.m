function [PixelOffset, SubPixelOffset, CorrAtOffset] = ...
    findStackOffset(Stack1, Stack2, MaxOffset)
%Estimates a sub-pixel offset between two stacks.


% Set default parameter values if needed.
if ~exist('MaxOffset', 'var')
    MaxOffset = [2, 2, 2];
end

% Ensure MaxOffset is a column vector for consistency.
if size(MaxOffset, 1) < size(MaxOffset, 2)
    MaxOffset = MaxOffset.';
end

% Determine dimensions relevant to the problem to improve code readability.
Stack1Size = size(Stack1);
Stack2Size = size(Stack2);
SizeOfFullXCorr = Stack1Size + Stack2Size - 1; % size of a full xcorr stack

% Ensure that the MaxOffset input is valid, modifying it's values if
% needed.
% NOTE: This is just ensuring that the MaxOffset corresponds to shifts
%       between the two stacks that still maintain some overlap.
IndicesToModify = find(MaxOffset > floor((SizeOfFullXCorr-1) / 2));
for ii = IndicesToModify.' % tranpose needed for for loop syntax
    warning('MaxOffset(%i) = %g is too big and was reset to %i', ...
        ii, MaxOffset(ii), floor((SizeOfFullXCorr(ii)-1) / 2))
    MaxOffset(ii) = floor((SizeOfFullXCorr(ii)-1) / 2);
end

% Scale each image in each stack by intensity to reduce linear trends in 
% the cross-correlation.
for ii = 1:Stack1Size(3)
    Stack1(:, :, ii) = Stack1(:, :, ii) / sum(sum(Stack1(:, :, ii)));
end
for ii = 1:Stack2Size(3)
    Stack2(:, :, ii) = Stack2(:, :, ii) / sum(sum(Stack2(:, :, ii)));
end

% Define the indices within a full cross-correlation (size SizeOfFullXCorr)
% that we wish to calculate.
CorrOffsetIndicesX = max(ceil(SizeOfFullXCorr(1)/2) - MaxOffset(1), 1) ...
    : ceil(SizeOfFullXCorr(1)/2) + MaxOffset(1);
CorrOffsetIndicesY = max(ceil(SizeOfFullXCorr(2)/2) - MaxOffset(2), 1) ...
    : ceil(SizeOfFullXCorr(2)/2) + MaxOffset(2);
CorrOffsetIndicesZ = max(ceil(SizeOfFullXCorr(3)/2) - MaxOffset(3), 1) ...
    : ceil(SizeOfFullXCorr(3)/2) + MaxOffset(3);

% Compute the brute-forced cross-correlation, considering only "small"
% offsets between the stacks.
XCorr3D = zeros(numel(CorrOffsetIndicesX), ...
    numel(CorrOffsetIndicesY), ...
    numel(CorrOffsetIndicesZ));
for ll = CorrOffsetIndicesX
    for mm = CorrOffsetIndicesY
        for nn = CorrOffsetIndicesZ
            % Isolate the sub-stacks of interest (the section of the stacks
            % which overlap in the current iteration).
            Stack1XIndices = ...
                max(1, ll-Stack1Size(1)+1):min(ll, Stack1Size(1));
            Stack1YIndices = ...
                max(1, mm-Stack1Size(2)+1):min(mm, Stack1Size(2));
            Stack1ZIndices = ...
                max(1, nn-Stack1Size(3)+1):min(nn, Stack1Size(3));
            SubStack1 = Stack1(Stack1XIndices, Stack1YIndices, ...
                Stack1ZIndices);
            Stack2XIndices = max(1, Stack2Size(1)-ll+1) ...
                : max(1, Stack2Size(1)-ll+1)+numel(Stack1XIndices)-1;
            Stack2YIndices = max(1, Stack2Size(2)-mm+1) ...
                : max(1, Stack2Size(2)-mm+1)+numel(Stack1YIndices)-1;
            Stack2ZIndices = max(1, Stack2Size(3)-nn+1) ...
                : max(1, Stack2Size(3)-nn+1)+numel(Stack1ZIndices)-1;
            SubStack2 = Stack2(Stack2XIndices, Stack2YIndices, ...
                Stack2ZIndices);              
            
            % Re-whiten the sub-stacks.
            SubStack1 = (SubStack1 - mean(SubStack1(:))) ...
                / (std(SubStack1(:)) * sqrt(numel(SubStack1(:)) - 1));
            SubStack2 = (SubStack2 - mean(SubStack2(:))) ...
                / (std(SubStack2(:)) * sqrt(numel(SubStack2(:)) - 1));
            
            % Compute the current point of the cross-correlation.
            XCorr3D(ll-min(CorrOffsetIndicesX)+1, ...
                mm-min(CorrOffsetIndicesY)+1, ...
                nn-min(CorrOffsetIndicesZ)+1) = ...
                SubStack1(:)' * SubStack2(:);
        end
    end
end

% Stack the 3D xcorr cube into a 1D array.  
% NOTE: MATLAB stacks columns in each 2D array (dimensions 1 and 2) then 
%       stacks the resulting columns along the third dimension, e.g. when
%       Array(:, :, 1) = [1, 3; 2, 4] and Array(:, :, 2) = [5, 7; 6, 8], 
%       Array(:) = [1, 2, 3, 4, 5, 6, 7, 8].' 
StackedCorrCube = XCorr3D(:);

% Determine the integer offset between the two stacks.
[~, IndexOfMax] = max(StackedCorrCube);
[PeakRow, PeakColumn, PeakHeight] = ind2sub(size(XCorr3D), IndexOfMax);
RawOffsetIndices = [PeakRow; PeakColumn; PeakHeight];

% Compute the integer offset by subtracting the found cross-correlation 
% peak.
% NOTE: We have to subtract MaxOffset+1 since the [0, 0, 0] offset will 
%       occur at MaxOffset+1 (e.g. the cross-correlation corresponds to
%       offsets of -MaxOffset:MaxOffset).
PixelOffset = RawOffsetIndices - MaxOffset - 1;

% Determine the repetition length(s), the length for which moving down the
% stacked array corresponds to a repeated index along one dimension, e.g.
% for Array above, Array(1:2) = [1, 2].' corresponds to column 1 
% (or x = 1).
RepLengthX = size(XCorr3D, 1);
RepLengthY = size(XCorr3D, 2);
RepLengthZMinor = size(XCorr3D, 3); % rep. for x, y arrays
RepLengthZMajor = numel(XCorr3D(:, :, 1)); % rep. for z array

% Create the repeated arrays for each dimension, noting that we must
% restart at index 1 for both x and y every RepLengthZ elements.
RepArrayX = (1:RepLengthX).'; % initialize
RepArrayX = repmat(RepArrayX, RepLengthX*RepLengthZMinor, 1);
RepArrayY = (1:RepLengthY).'; % initialize
RepArrayY = repelem(RepArrayY, RepLengthY);
RepArrayY = repmat(RepArrayY, RepLengthZMinor, 1);
RepArrayZ = (1:RepLengthZMinor).'; % initialize
RepArrayZ = repelem(RepArrayZ, RepLengthZMajor);

% Compute the least-squares solution for the polynomial parameters.
X = [ones(numel(StackedCorrCube), 1), RepArrayX, RepArrayX.^2, ...
    RepArrayY, RepArrayY.^2, RepArrayZ, RepArrayZ.^2, ...
    RepArrayX.*RepArrayY, RepArrayY.*RepArrayZ, RepArrayZ.*RepArrayX];
Lambda = 0; % ridge regression parameter
Beta = ((X.'*X + Lambda*eye(size(X, 2))) \ X.') * StackedCorrCube;

% Build our approximate solution as an anonymous function to easily compute
% values at certain pixels.
PolyFitFunction = @(R) Beta(1) + Beta(2)*R(1) + Beta(3)*R(1).^2 ...
    + Beta(4)*R(2) + Beta(5)*R(2).^2 ...
    + Beta(6)*R(3) + Beta(7)*R(3).^2 ...
    + Beta(8)*R(1)*R(2) + Beta(9)*R(2)*R(3) + Beta(10)*R(3)*R(1);
% PolyFitArray = Beta(1) + Beta(2)*RepArrayX + Beta(3)*RepArrayX.^2 ...
%     + Beta(4)*RepArrayY + Beta(5)*RepArrayY.^2 ...
%     + Beta(6)*RepArrayZ + Beta(7)*RepArrayZ.^2 ...
%     + Beta(8)*RepArrayX.*RepArrayY ...
%     + Beta(9)*RepArrayY.*RepArrayZ ...
%     + Beta(10)*RepArrayZ.*RepArrayX;
% PolyFitMatrix = reshape(PolyFitArray, size(XCorr3D));

% Determine the raw index offset based on the peak location of the
% polynomial, computing the matrix form found by maximizing the fitted 
% polynomial (i.e. set gradient of polynomial to 0 vector, solve with
% matrix equation).
RawOffsetFit = [2*Beta(3), Beta(8), Beta(10); ...
    Beta(8), 2*Beta(5), Beta(9); ...
    Beta(10), Beta(9), 2*Beta(7)] \ -[Beta(2); Beta(4); Beta(6)];

% Determine the predicted offset between the stack.
% NOTE: We subtract MaxOffset+1 because that is the location of the 
%       [0, 0, 0] offset (the center of the cross-correlation).
SubPixelOffset = RawOffsetFit - MaxOffset - 1;

% % Determine if the fit is worth using, or if we should stick to the integer
% % shift found earlier.
% % NOTE: If the offset predicted by the fit is greater than 0.5 pixels from 
% %       the integer offset prediction, we will just use the integer offset
% %       prediction.
% PixelOffset = PixelOffset .* (abs(PixelOffset-IntegerOffset) <= 0.5) ...
%     + IntegerOffset .* (abs(PixelOffset-IntegerOffset) > 0.5);

% Determine the correlation coefficient of the polynomial fit at the
% selected offset.
CorrAtOffset = PolyFitFunction(SubPixelOffset + MaxOffset + 1);

end