function H = hog_propio_2(I)
%%
%
celdaSz=8;
blSz=2;
bins=9;

total_angles = 180.0;
bin_width = total_angles/bins;

%% Para mapear los centros de los intervalos
bin_centers_map = (bin_width/2:bin_width:total_angles)';

%%hallar el gradiente
[angsGrad, magsGrad] = gradiente(I);

%% Split the gradient in cells
coordCeldas = coordenadas(angsGrad,celdaSz,celdaSz);

%% initialize 3 dimensional matrix to hold all the histograms
% number of vertical and horizontal cells
[height,width] = size(I(:,:,1));
n_v_cells = floor(height/celdaSz);
n_h_cells = floor(width/celdaSz);

% init the histograms 3D matrix (7x14x9)
histograms = zeros(n_v_cells,n_h_cells,bins);



% ================================================
%% Computing histograms for all image cells
% ================================================
for index=1:size(coordCeldas,2)
    
    % current cell histogram initialization
    h = zeros(1,bins);
    
    % cell coords
    x_min = coordCeldas(1,index);
    x_max = coordCeldas(2,index);
    y_min = coordCeldas(3,index);
    y_max = coordCeldas(4,index);

    % retrieve angles and magnitudes for all the pixels in the 
    % cell and conversion to degrees.
    angs = angsGrad(y_min:y_max,x_min:x_max);
    angs = angs.*180/pi;
    mags = magsGrad(y_min:y_max,x_min:x_max);

    % indices for the left and right histogram bins that bound
    % the current angle value for all the pixels in the cell
    left_indices = round(angs/bin_width);
    right_indices = left_indices+1;

    % wraping contributions over the histogram boundaries.
    left_indices(left_indices==0) = 9;
    right_indices(right_indices==10) = 1;
    
    % retrieving the left bin center value.
    left_bin_centers = bin_centers_map(left_indices);
    angs(angs < left_bin_centers) = ...
        total_angles + angs(angs < left_bin_centers);
    
    
    % calculating the contribution to both bins sides (vote weight)
    % (matrices with same size as the cell)
    right_contributions = (angs-left_bin_centers)/bin_width;
    left_contributions = 1 - right_contributions;
    left_contributions = mags.*left_contributions;
    right_contributions = mags.*right_contributions;
    

    % computing contributions for the current histogram bin by bin.
    for bin=1:bins
        % pixels that contribute to the bin with its left portion
        pixels_to_left = (left_indices == bin);
        h(bin) = h(bin) + sum(left_contributions(pixels_to_left));
        
        % pixels that contribute to the bin with its right portion
        pixels_to_right = (right_indices == bin);
        h(bin) = h(bin) + sum(right_contributions(pixels_to_right));
    end

    % appending current hist. to the histograms matrix
    row_offset = floor(index/n_h_cells + 1);
    column_offset = mod(index-1,n_h_cells)+1;
    histograms(row_offset,column_offset,:) = h(1,:);

end

% ================================================
%%          block normalization (L2 norm)
% ================================================
hist_size = blSz*blSz*bins;
% descriptor_size = hist_size*(n_v_cells-block_size+desp)*(n_h_cells-block_size+desp);
% H = zeros(descriptor_size, 1);
col = 1;
row = 1;
H = [];

%% Split the histogram matrix in blocks (this code assumes an 50% of overlap as desp is hard coded as 1)
while row <= n_v_cells-blSz+1
    while col <= n_h_cells-blSz+1
        
        % Getting all the histograms for a block
        blockHists = ...
            histograms(row:row+blSz-1, col:col+blSz-1, :);
        
        % Getting the magnitude of the histograms of the block
        magnitude = norm(blockHists(:));
    
        % Divide all of the histogram values by the magnitude to normalize 
        % them.
        normalized = blockHists / (magnitude + 0.0001);

        % H = [H; normalized(:)];
        offset = (row-1)*(n_h_cells-blSz+1)+col;
        ini = (offset-1)*hist_size+1;
        fin = offset*hist_size;

        H(ini:fin,1) = normalized(:);

        col = col+1;
    end
    row = row+1;
    col = 1;
end
