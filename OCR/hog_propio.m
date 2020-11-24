% I=rgb2gray(imread('TEST_2.jpg'));
% I=imresize(42,24);
% a=computeHOG(I, 2, 2, 4, 4);

function h=hog_propio(img, cellWidth, cellHeight, blockWidth, blockHeight)
	[hei, wid, dim] = size(img);
	% If RGB, convert to GRAY
	if dim == 3
		img = rgb2gray(img);
	end
	img = double(img);
	blockPixelWidth = cellWidth * blockWidth;
	blockPixelHeight = cellHeight * blockHeight;
	% Num pixels vertically and horizontally in BLOCK must be even (should be dividable by 2), as there is 50% overlapping
	if mod(blockPixelWidth, 2) ~= 0
		error('At least one of {cellWidth, blockWidth} must be even, as blocks are exactly 50% overlapping');
	end
	if mod(blockPixelHeight, 2) ~= 0
		error('At least one of {cellHeight, blockHeight} must be even, as blocks are exactly 50% overlapping');
	end
	% Block size must not be larger than image size
	if (blockPixelHeight > hei || blockPixelWidth > wid)
		error('Block size in pixels is larger than image size');
	end
	% Image width must be dividable by half of block pixel width, so if fits to num of blocks with 50% overlapping. Same for height
	% To clarify, the image width can only be one of [1, 1.5, 2, 2.5, 3, 3.5, ...] times the block width in pixels
	blockPixelHalfWidth = blockPixelWidth / 2;
	blockPixelHalfHeight = blockPixelHeight / 2;
	if mod(wid, blockPixelHalfWidth) ~= 0
		error('Sizes of cells and blocks do not fit to size of image with 50% overlapping');
	end
	if mod(hei, blockPixelHalfHeight) ~= 0
		error('Sizes of cells and blocks do not fit to size of image with 50% overlapping');
	end

	[gx,gy] = imgradientxy(img);
	magn = sqrt((gx .^ 2) + (gy .^ 2));
	% Note that "atan" values are only in [-90.0, 90.0]
	% If we want it in [0, 360], we need to check:
	%  If value > 0, it means that derX,derY > 0 OR derX,derY < 0   ==> If greater, leave as is. If less, add 180
	%  If value < 0, it means that derX < 0 OR derY < 0   ==> If derY < 0, leave as is. If derX < 0, add 180
	%
	% We currently do not care about signs, so just adding 180 to the negative angles (flipping them to the positive side)
	direc = atan(gy ./ gx) .* (180 / pi);
	negativeVals = direc(direc < 0);
	negativeVals = negativeVals + 180;
	direc(direc < 0) = negativeVals;
	% Binning into 9 bins: 0-20, 20-40, 40-60, ...., 160-180
	binnedDirec = floor(direc / 20) + 1;
	% If there is any angle with the maximal value of 180 degrees ==> we get (180 / 20 + 1 = 10), exceeding number of bins 
	%    ==> hence moving it to the 9th and the last bin, of 160-180 degrees
	binnedDirec(binnedDirec > 9) = 9;
	% Computing final vec
	% There is a block starting from each pixel dividable by "blockPixelHalfWidth", except for the last one. Hence, "-1" (same for Height)
	numBlocksWidth = wid / blockPixelHalfWidth - 1;
	numBlocksHeight = hei / blockPixelHalfHeight - 1;
	blockVecLen = blockWidth * blockHeight * 9;
	hogVec = zeros(1, numBlocksWidth * numBlocksHeight * blockVecLen);
	vecStart = 1;
	for i = 1:numBlocksWidth
		widthStart = (i - 1) * blockPixelHalfWidth + 1;
		for j = 1:numBlocksHeight
			heightStart = (j - 1) * blockPixelHalfHeight + 1;
			blockDir = binnedDirec(heightStart:heightStart + blockPixelHeight - 1 ,widthStart:widthStart + blockPixelWidth - 1);
			blockMagn = magn(heightStart:heightStart + blockPixelHeight - 1 ,widthStart:widthStart + blockPixelWidth - 1);
			blockHOG = computeBlockVector(blockDir, blockMagn, cellWidth, cellHeight);
			hogVec(vecStart:vecStart + blockVecLen - 1) = blockHOG;
			vecStart = vecStart + blockVecLen;
		end
	end
end

function computeBlockVector(blockDir, blockMagn, cellWidth, cellHeight)
	[hei, wid] = size(blockDir);

	numCellsWidth = wid / cellWidth;
	numCellsHeight = hei / cellHeight;
	
	% We have a histogram for each cell, where each histogram has 9 bins
	vec = zeros(1, numCellsWidth * numCellsHeight * 9);
	vecStart = 0;
	for i = 1:numCellsWidth
		cellWidStart = (i - 1) * cellWidth + 1;
		for j = 1:numCellsHeight
			cellHeiStart = (j - 1) * cellHeight + 1;
			% Taking the cell's sub-matrices of direction and of magnitude
			cellDir = blockDir(cellHeiStart:cellHeiStart + cellHeight - 1, cellWidStart:cellWidStart + cellWidth - 1);
			cellMagn = blockMagn(cellHeiStart:cellHeiStart + cellHeight - 1, cellWidStart:cellWidStart + cellWidth - 1);
			
			% Assigning the values to the main vector, in the current cell's allocated 9 indices
			% The values are actually: for bin "x" - the sum of magnitudes for pixels with direction "x"
			for b = 1:9
				vec(vecStart + b) = sum(cellMagn(cellDir == b));
			end
			
			vecStart = vecStart + 9;
		end
	end
	% Normalizing vector - dividing each v[i] in:  sqrt(v[1]^2 + v[2]^2 + ... + v[n]^2 + epsilon^2)
	vecPow = vec .^ 2;
	epsilon = 1;
	n2 = sqrt(sum(vecPow) + (epsilon ^ 2));
	vec / n2;
end