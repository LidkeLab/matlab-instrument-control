function [PixelOffset, SubPixelOffset, CorrAtOffset, MaxOffset] = ...
    findStackOffset(Stack1, Stack2, MaxOffset, Method, FitType, FitOffset)
%findStackOffset estimates a sub-pixel offset between two stacks.
% findStackoffset() will estimate the offset between two 3D stacks of
% images.  This method computes an integer pixel offset between the two
% stacks via a cross-correlation (xcorr) or an xcorr like method, and
% then fits a 2nd order polynomial to the resulting xcorr.  An
% estimate of a sub-pixel offset is then produced by determining the
% location of the peak in the 2nd order polynomial fit. 
% NOTE: The convention used here for the offset is based on indices as
%       follows: If Stack is a 3D stack of images, and
%       Stack1 = Stack(m:n, m:n, m:n) 
%       Stack2 = Stack((m:n)+x, (m:n)+y, (m:n)+z)
%       then PixelOffset = findStackOffset(Stack1, Stack2) == [x; y; z]
%
% INPUTS:
%   Stack1:     (mxnxo) The stack to which Stack2 is compared to, i.e. 
%               Stack1 is the reference stack.
%   Stack2:     (pxqxr) The stack for which the offset relative to Stack1 
%               is to be determined.
%   MaxOffset:  (3x1 or 1x3)(default = [2; 2; 2]) Maximum offset between 
%               Stack1 and Stack2 to be considered in the calculation of
%               PixelOffset and SubPixelOffset.
%   Method:     (string/character array)(default = 'FFT') Method used to
%               compute the 3D xcorr coefficient field or xcorr like 
%               coefficient field.  
%               'FFT' uses an FFT on the stacks (which are also 'whitened', 
%                   i.e. mean subtracted and scaled by their 
%                   auto-correlation) to compute a xcorr coefficient field 
%                   which is then appropriately scaled by the xcorr 
%                   coefficient field of two binary stacks of size(Stack1), 
%                   size(Stack2), respectively.
%               'OLRW' computes an xcorr like coefficient field by brute
%                   force, meaning that the coefficient field is computed 
%                   like a xcorr but the overlapping portions of Stack1 and 
%                   Stack2 are  re-whitened for the computation of each
%                   point in the xcorr coefficient field.
%   FitType:    (string/character array)(default = '1D') The type 
%               of polynomial fit used to fit the 3D xcorr coefficient 
%               field.
%               '1D' fits 2nd order polynomials to three lines parallel to
%                   x, y, and z which intersect the integer peak of the 
%                   xcorr coefficient field.  The fit is determined via 
%                   least-squares independently for each of the three 
%                   polynomials. Note that only 2 points on either side of 
%                   the peak are incorporated into the fitting (5 points 
%                   total, unless near an edge).
%               '3D' fits a 2nd order polynomial (with cross terms) to the 
%                   3D xcorr coefficient field using the least-squares 
%                   method.
%               '3DLineFits' fits a 2nd order polynomial (w/o cross terms) 
%                   to three lines parallel to x, y, and z which intersect 
%                   the integer peak of the xcorr coefficient field.  
%                   Unlike in the '1D' method, the polynomial fit for this 
%                   method is computed via the least-squares method in a 
%                   global sense, i.e. we fit the 3D polynomial (w/o cross 
%                   terms) to the union of the data along all three lines.  
%                   Note that only 2 points on either side of the peak are 
%                   incorporated into the fitting (5 points total, unless 
%                   near an edge).
%   FitOffset:  (3x1 or 1x3)(default = [2; 2; 2]) Maximum offset from the
%               peak of the cross-correlation curve for which data will be
%               fit to determine SubPixelOffset.  This only applies to
%               FitType = '1D' or '3DLineFits'.
%
% OUTPUTS:
%   PixelOffset:    (3x1)(integer) The integer pixel offset of Stack2
%                   relative to Stack1, determined based on the location of
%                   the peak of the xcorr coefficient field between the two
%                   stacks.
%   SubPixelOffset: (3x1)(float) The sub-pixel offset of Stack2 relative to
%                   Stack1, approximated based on a 2nd order polynomial 
%                   fit(s) to the xcorr coefficient field as specified by 
%                   the FitType input and finding the peak of that 
%                   polynomial.
%   CorrAtOffset:   (float) The maximum value of the correlation
%                   coefficient, corresponding to the correlation
%                   coefficient at the offset given by PixelOffset.
%   MaxOffset:      (3x1 or 1x3) Maximum offset between Stack1 and Stack2 
%                   considered in the calculation of PixelOffset and 
%                   SubPixelOffset.  This is returned because the user
%                   input value of MaxOffset is truncated if too large. 
% 
% CITATION:

% Created by:
%   David Schodt (LidkeLab 2018)


% Set default parameter values if needed.
if ~exist('MaxOffset', 'var')
    MaxOffset = [2; 2; 2];
end
if ~exist('Method', 'var')
    Method = 'FFT';
end
if ~exist('FitType', 'var')
    FitType = '1D';
end

% Ensure the stacks are floating point arrays.
if ~isfloat(Stack1) || ~isfloat(Stack2)
    Stack1 = double(Stack1);
    Stack2 = double(Stack2);
end

% Ensure MaxOffset is a column vector for consistency.
if size(MaxOffset, 1) < size(MaxOffset, 2)
    MaxOffset = MaxOffset.';
end

% Determine dimensions relevant to the problem to improve code readability.
Stack1Size = size(Stack1).';
Stack2Size = size(Stack2).';
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
% that we wish to inspect.
CorrOffsetIndicesX = max(ceil(SizeOfFullXCorr(1)/2) - MaxOffset(1), 1) ...
    : ceil(SizeOfFullXCorr(1)/2) + MaxOffset(1);
CorrOffsetIndicesY = max(ceil(SizeOfFullXCorr(2)/2) - MaxOffset(2), 1) ...
    : ceil(SizeOfFullXCorr(2)/2) + MaxOffset(2);
CorrOffsetIndicesZ = max(ceil(SizeOfFullXCorr(3)/2) - MaxOffset(3), 1) ...
    : ceil(SizeOfFullXCorr(3)/2) + MaxOffset(3);

% Compute the cross-correlation based on the method specified by Method.
switch Method
    case 'FFT'
        % Compute the standard cross-correlation based on the FFT, but
        % inspect only the central portion corresponding to MaxOffset
        % offsets along each dimension.
        
        % Whiten each image in the stack with respect to the entire stack.
        Stack1Whitened = (Stack1 - mean(Stack1(:))) ...
            / (std(Stack1(:)) * sqrt(numel(Stack1(:)) - 1));
        Stack2Whitened = (Stack2 - mean(Stack2(:))) ...
            / (std(Stack2(:)) * sqrt(numel(Stack2(:)) - 1));

        % Compute the zero-padded 3D FFT's of each stack.
        Stack1PaddedFFT = fftn(Stack1Whitened, 2*size(Stack1Whitened)-1);
        Stack2PaddedFFT = fftn(Stack2Whitened, 2*size(Stack2Whitened)-1);
        
        % Compute the 3D cross-correlation in the Fourier domain.
        XCorr3D = ifftn(conj(Stack1PaddedFFT) .* Stack2PaddedFFT);
        
        % Compute the binary cross-correlation for later use in scaling.
        Stack1Binary = ones(size(Stack1Whitened));
        Stack2Binary = ones(size(Stack2Whitened));
        Stack1BinaryFFT = fftn(Stack1Binary, 2*size(Stack1Whitened)-1);
        Stack2BinaryFFT = fftn(Stack2Binary, 2*size(Stack2Whitened)-1);
        XCorr3DBinary = ifftn(conj(Stack1BinaryFFT) .* Stack2BinaryFFT);

        % Scale the 3D cross-correlation by the cross-correlation of the
        % zero-padded binary images (an attempt to reduce the bias to a 
        % [0, 0, 0] offset introduced by the zero-padded edge effects),
        % scaling by max(XCorr3DBinary(:)) to re-convert to a correlation
        % coefficient.
        XCorr3D = (XCorr3D ./ XCorr3DBinary) ...
            * min(numel(Stack1Binary), numel(Stack2Binary));
        
        % Shift the cross-correlation image such that an auto-correlation 
        % image will have it's energy peak at the center of the 3D image.
        XCorr3D = circshift(XCorr3D, size(Stack1Whitened) - 1);

        % Isolate the central chunk of the cross-correlation and the
        % binary cross-correlation.
        XCorr3D = XCorr3D(CorrOffsetIndicesX, ...
            CorrOffsetIndicesY, ...
            CorrOffsetIndicesZ); % center of our cross-correlation 
    case 'OLRW'
        % Compute the brute-forced cross-correlation, considering only
        % "small" offsets between the stacks.
        XCorr3D = zeros(numel(CorrOffsetIndicesX), ...
            numel(CorrOffsetIndicesY), ...
            numel(CorrOffsetIndicesZ));
        for ll = CorrOffsetIndicesX
            for mm = CorrOffsetIndicesY
                for nn = CorrOffsetIndicesZ
                    % Isolate the sub-stacks of interest (the section of 
                    % the stacks which overlap in the current iteration).
                    Stack1XIndices = ...
                        max(1, ll-Stack1Size(1)+1):min(ll, Stack1Size(1));
                    Stack1YIndices = ...
                        max(1, mm-Stack1Size(2)+1):min(mm, Stack1Size(2));
                    Stack1ZIndices = ...
                        max(1, nn-Stack1Size(3)+1):min(nn, Stack1Size(3));
                    SubStack1 = Stack1(Stack1XIndices, Stack1YIndices, ...
                        Stack1ZIndices);
                    Stack2XIndices = max(1, Stack2Size(1)-ll+1) ...
                        : max(1, Stack2Size(1)-ll+1) ...
                        + numel(Stack1XIndices)-1;
                    Stack2YIndices = max(1, Stack2Size(2)-mm+1) ...
                        : max(1, Stack2Size(2)-mm+1) ...
                        + numel(Stack1YIndices)-1;
                    Stack2ZIndices = max(1, Stack2Size(3)-nn+1) ...
                        : max(1, Stack2Size(3)-nn+1) ...
                        + numel(Stack1ZIndices)-1;
                    SubStack2 = Stack2(Stack2XIndices, Stack2YIndices, ...
                        Stack2ZIndices);
                    
                    % Re-whiten the sub-stacks.
                    SubStack1 = (SubStack1 - mean(SubStack1(:))) ...
                        / (std(SubStack1(:)) ...
                        * sqrt(numel(SubStack1(:)) - 1));
                    SubStack2 = (SubStack2 - mean(SubStack2(:))) ...
                        / (std(SubStack2(:)) ...
                        * sqrt(numel(SubStack2(:)) - 1));
                    
                    % Compute the current point of the cross-correlation.
                    XCorr3D(ll - min(CorrOffsetIndicesX) + 1, ...
                        mm - min(CorrOffsetIndicesY) + 1, ...
                        nn - min(CorrOffsetIndicesZ) + 1) = ...
                        SubStack1(:)' * SubStack2(:);
                end
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
[CorrAtOffset, IndexOfMax] = max(StackedCorrCube);
[PeakRow, PeakColumn, PeakHeight] = ind2sub(size(XCorr3D), IndexOfMax);
RawOffsetIndices = [PeakRow; PeakColumn; PeakHeight];

% Compute the integer offset by subtracting the found cross-correlation 
% peak.
% NOTE: For the OLRW method, we have to subtract MaxOffset+1 since the 
%           [0, 0, 0] offset will occur at MaxOffset+1 (e.g. the 
%           cross-correlation corresponds to offsets of 
%           -MaxOffset:MaxOffset).
%       For the FFT method, which obtains the more standard form of the
%       xcorr, we include an additional minus sign in the found offset to
%       account for an additional spatial reversal not captured by the OLRW
%       method.
PixelOffset = RawOffsetIndices - MaxOffset - 1;
if strcmpi(Method, 'FFT')
    PixelOffset = -PixelOffset;
end

% Fit the cross-correlation based on input FitType.
switch FitType
    case '3D'
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
            RepArrayX.*RepArrayY, RepArrayY.*RepArrayZ, ...
            RepArrayZ.*RepArrayX];
        Lambda = 0; % ridge regression parameter
        Beta = ((X.'*X + Lambda*eye(size(X, 2))) \ X.') * StackedCorrCube;
        
        % Determine the raw index offset based on the peak location of the
        % polynomial, computing the matrix form found by maximizing the 
        % fitted polynomial (i.e. set gradient of polynomial to 0 vector, 
        % solve with matrix equation).
        RawOffsetFit = [2*Beta(3), Beta(8), Beta(10); ...
            Beta(8), 2*Beta(5), Beta(9); ...
            Beta(10), Beta(9), 2*Beta(7)] \ -[Beta(2); Beta(4); Beta(6)];

        % Build our approximate solution as an anonymous function to easily 
        % compute values at certain pixels.
        PolyFitFunction = @(R) ...
            Beta(1) + Beta(2)*R(1, :) + Beta(3)*R(1, :).^2 ...
            + Beta(4)*R(2, :) + Beta(5)*R(2, :).^2 ...
            + Beta(6)*R(3, :) + Beta(7)*R(3, :).^2 ...
            + Beta(8)*R(1, :).*R(2, :) ...
            + Beta(9)*R(2, :).*R(3, :) ...
            + Beta(10)*R(3, :).*R(1, :);
        
        % Construct appropriate arrays corresponding to x,y,z that 
        % intersect the max integer offset found above (to be used later).
        XArrayDense = linspace(1, 2*MaxOffset(1)+1, size(Stack1, 1));
        YArrayDense = linspace(1, 2*MaxOffset(2)+1, size(Stack1, 1));
        ZArrayDense = linspace(1, 2*MaxOffset(3)+1, size(Stack1, 1));
        XPeakArray = ones(1, numel(XArrayDense)) * RawOffsetIndices(1);
        YPeakArray = ones(1, numel(YArrayDense)) * RawOffsetIndices(2);
        ZPeakArray = ones(1, numel(ZArrayDense)) * RawOffsetIndices(3);
        XFitAtPeak = PolyFitFunction(...
            [XArrayDense; YPeakArray; ZPeakArray]);
        YFitAtPeak = PolyFitFunction(...
            [XPeakArray; YArrayDense; ZPeakArray]);
        ZFitAtPeak = PolyFitFunction(...
            [XPeakArray; YPeakArray; ZArrayDense]);
    case '3DLineFits'
        % Fit a second order polynomial through the 3 lines parallel to
        % x, y, z of the cross-correlation which intersect the (integer)
        % peak.
        
        % Create the index vectors appropriate for this fit.  As an
        % example, at the peak, the line parallel to x could correspond to
        % x = [1, 2, 3], so y = [y_at_max, y_at_max, y_at_max] 
        % and z = [z_at_max, z_at_max, z_at_max].
        XArray = (max(1, RawOffsetIndices(1)-FitOffset(1)) ...
            : min(2*MaxOffset(1)+1, RawOffsetIndices(1)+FitOffset(1))).';
        YArray = (max(1, RawOffsetIndices(2)-FitOffset(2)) ...
            : min(2*MaxOffset(2)+1, RawOffsetIndices(2)+FitOffset(2))).';
        ZArray = (max(1, RawOffsetIndices(3)-FitOffset(3)) ...
            : min(2*MaxOffset(3)+1, RawOffsetIndices(3)+FitOffset(3))).';
        RepArrayX = [XArray; ...
            ones(numel(YArray) + numel(ZArray), 1) ...
            * RawOffsetIndices(1)]; % full x array for all three lines
        RepArrayY = [ones(numel(XArray), 1) * RawOffsetIndices(2); ...
            YArray; ...
            ones(numel(ZArray), 1) * RawOffsetIndices(2)]; % full y array
        RepArrayZ = [ones(numel(XArray) + numel(YArray), 1) ...
            * RawOffsetIndices(3); ...
            ZArray]; % full z array for all three lines
        
        % Create an array of the xcorr data corresponding to the three
        % lines described above.
        XData = XCorr3D(XArray, RawOffsetIndices(2), RawOffsetIndices(3)); 
        YData = ...
            XCorr3D(RawOffsetIndices(1), YArray, RawOffsetIndices(3)).';
        ZData = squeeze(...
            XCorr3D(RawOffsetIndices(1), RawOffsetIndices(2), ZArray));
        LineCorrData = [XData; YData; ZData];
        
        % Compute the least-squares solution for the polynomial parameters.
        X = [ones(numel(LineCorrData), 1), RepArrayX, RepArrayX.^2, ...
            RepArrayY, RepArrayY.^2, RepArrayZ, RepArrayZ.^2];
        Lambda = 0; % ridge regression parameter
        Beta = ((X.'*X + Lambda*eye(size(X, 2))) \ X.') * LineCorrData;
        
        % Determine the raw index offset based on the peak location of the
        % polynomial, computing the matrix form found by maximizing the 
        % fitted polynomial (i.e. set gradient of polynomial to 0 vector, 
        % solve with matrix equation).
        RawOffsetFit = [-Beta(2) / (2 * Beta(3)); ...
            -Beta(4) / (2 * Beta(5)); ...
            -Beta(6) / (2 * Beta(7))];

        % Build our approximate solution as an anonymous function to easily 
        % compute values at certain pixels.
        PolyFitFunction = @(R) Beta(1) ...
            + Beta(2)*R(1, :) + Beta(3)*R(1, :).^2 ...
            + Beta(4)*R(2, :) + Beta(5)*R(2, :).^2 ...
            + Beta(6)*R(3, :) + Beta(7)*R(3, :).^2;
        
        % Construct appropriate arrays corresponding to x,y,z that 
        % intersect the max integer offset found above (to be used later).
        XArrayDense = linspace(XArray(1), XArray(end), size(Stack1, 1));
        YArrayDense = linspace(YArray(1), YArray(end), size(Stack1, 1));
        ZArrayDense = linspace(ZArray(1), ZArray(end), size(Stack1, 1));
        XPeakArray = ones(1, numel(XArrayDense)) * RawOffsetIndices(1);
        YPeakArray = ones(1, numel(YArrayDense)) * RawOffsetIndices(2);
        ZPeakArray = ones(1, numel(ZArrayDense)) * RawOffsetIndices(3);
        XFitAtPeak = PolyFitFunction(...
            [XArrayDense; YPeakArray; ZPeakArray]);
        YFitAtPeak = PolyFitFunction(...
            [XPeakArray; YArrayDense; ZPeakArray]);
        ZFitAtPeak = PolyFitFunction(...
            [XPeakArray; YPeakArray; ZArrayDense]);       
    case '1D'
        % Fit a second order polynomial through a line varying with x
        % at the peak of the cross-correlation in y, z, and use that
        % polynomial to predict an offset.  If possible, center the fit 
        % around the integer peak of the cross-correlation.
        % NOTE: This only fits to a total of five datapoints.
        XArray = (max(1, RawOffsetIndices(1)-FitOffset(1)) ...
            : min(2*MaxOffset(1)+1, RawOffsetIndices(1)+FitOffset(1))).';
        XData = XCorr3D(XArray, RawOffsetIndices(2), RawOffsetIndices(3));
        X = [ones(numel(XArray), 1), XArray, XArray.^2];
        Lambda = 0; % ridge regression parameter
        Beta = ((X.'*X + Lambda*eye(size(X, 2))) \ X.') * XData;
        RawOffsetFitX = -Beta(2) / (2 * Beta(3));
        PolyFitFunctionX = @(R) Beta(1) + Beta(2)*R + Beta(3)*R.^2;
        
        % Fit a second order polynomial through a line varying with y
        % at the peak of the cross-correlation in x, z.
        YArray = (max(1, RawOffsetIndices(2)-FitOffset(2)) ...
            : min(2*MaxOffset(2)+1, RawOffsetIndices(2)+FitOffset(2))).';
        YData = ...
            XCorr3D(RawOffsetIndices(1), YArray, RawOffsetIndices(3)).';
        X = [ones(numel(YArray), 1), YArray, YArray.^2];
        Lambda = 0; % ridge regression parameter
        Beta = ((X.'*X + Lambda*eye(size(X, 2))) \ X.') * YData;
        RawOffsetFitY = -Beta(2) / (2 * Beta(3));
        PolyFitFunctionY = @(R) Beta(1) + Beta(2)*R + Beta(3)*R.^2;        
        
        % Fit a second order polynomial through a line varying with z
        % at the peak of the cross-correlation in x, y.
        ZArray = (max(1, RawOffsetIndices(3)-FitOffset(3)) ...
            : min(2*MaxOffset(3)+1, RawOffsetIndices(3)+FitOffset(3))).';
        ZData = squeeze(...
            XCorr3D(RawOffsetIndices(1), RawOffsetIndices(2), ZArray));
        X = [ones(numel(ZArray), 1), ZArray, ZArray.^2];
        Lambda = 0; % ridge regression parameter
        Beta = ((X.'*X + Lambda*eye(size(X, 2))) \ X.') * ZData;
        RawOffsetFitZ = -Beta(2) / (2 * Beta(3));
        PolyFitFunctionZ = @(R) Beta(1) + Beta(2)*R + Beta(3)*R.^2;
            
        % Create arrays of the polynomial fits to use for visualization
        % later on.
        XArrayDense = linspace(XArray(1), XArray(end), size(Stack1, 1));
        YArrayDense = linspace(YArray(1), YArray(end), size(Stack1, 2));
        ZArrayDense = linspace(ZArray(1), ZArray(end), size(Stack1, 3));
        XFitAtPeak = PolyFitFunctionX(XArrayDense);
        YFitAtPeak = PolyFitFunctionY(YArrayDense);
        ZFitAtPeak = PolyFitFunctionZ(ZArrayDense);
        
        % Compute the predicted offset based on the polynomial fits.
        RawOffsetFit = [RawOffsetFitX; RawOffsetFitY; RawOffsetFitZ];
end

% Determine the predicted offset between the stack.
% NOTE: We subtract MaxOffset+1 because that is the location of the 
%       [0, 0, 0] offset (the center of the cross-correlation).
SubPixelOffset = RawOffsetFit - MaxOffset - 1;
if strcmpi(Method, 'FFT')
    SubPixelOffset = -SubPixelOffset;
end

% Display line sections through the integer location of the
% cross-correlation, overlain on the fit along those lines.
FigureWindow = findobj('Tag', 'CorrWindow');
if isempty(FigureWindow)
    FigureWindow = figure('Tag', 'CorrWindow');
end
clf(FigureWindow); % clear the figure window
figure(FigureWindow); % ensure we plot into the correct figure
subplot(3, 1, 1)
plot(-MaxOffset(1):MaxOffset(1), ...
    XCorr3D(:, RawOffsetIndices(2), RawOffsetIndices(3)), 'x')
hold on
plot(XArrayDense-MaxOffset(1)-1, XFitAtPeak)
title('X Correlation')
subplot(3, 1, 2)
plot(-MaxOffset(2):MaxOffset(2), ...
    XCorr3D(RawOffsetIndices(1), :, RawOffsetIndices(3)), 'x')
hold on
plot(YArrayDense-MaxOffset(2)-1, YFitAtPeak)
title('Y Correlation')
ylabel('Correlation Coefficient')
subplot(3, 1, 3)
plot(-MaxOffset(3):MaxOffset(3), ...
    squeeze(XCorr3D(RawOffsetIndices(1), RawOffsetIndices(2), :)), 'x')
hold on
plot(ZArrayDense-MaxOffset(3)-1, ZFitAtPeak)
title('Z Correlation')
xlabel('Pixel Offset')

end