function H = hog_propio_2(I)
%%

celdaSz=8;
blSz=2;
bins=9;

tAngs = 180.0;
anchoInt = tAngs/bins;

%% Para mapear los centros de los intervalos
mCentrInt = (anchoInt/2:anchoInt:tAngs)';

%% Calcular el gradiente
[angsGrad, magsGrad] = gradiente(I);

%% Seccionar imagen en celdas
coordCeldas = coordenadas(angsGrad,celdaSz,celdaSz);

%% Inicializar matriz de histogramas
% Celdas horizontales y verticales
[he,wi] = size(I(:,:,1));
numVCells = floor(he/celdaSz);
numHCells = floor(wi/celdaSz);

% Matriz de los histogramas
histogramas = zeros(numVCells,numHCells,bins);


%% Histograma de todas las celdas en la imagen
for counter=1:size(coordCeldas,2)
    
    % Inicializar histograma de la celda actual
    h = zeros(1,bins);
    
    % Coordenadas de las celdas
    xMin = coordCeldas(1,counter);
    xMax = coordCeldas(2,counter);
    yMin = coordCeldas(3,counter);
    yMax = coordCeldas(4,counter);

    % Direcciones y magnitudes para los pixeles
    % en las celdas
    angs = angsGrad(yMin:yMax,xMin:xMax);
    angs = angs.*180/pi;
    mags = magsGrad(yMin:yMax,xMin:xMax);

    % Indices de los intervalos izquierdo y derecho que limitan
    lIndices = round(angs/anchoInt);
    rIndices = lIndices+1;

    % Contribuciones en el histograma
    lIndices(lIndices==0) = 9;
    rIndices(rIndices==10) = 1;
    
    % Recuperar el retrieving the left bin center value.
    lInt_centers = mCentrInt(lIndices);
    angs(angs < lInt_centers) = ...
        tAngs + angs(angs < lInt_centers);
    
    
    % Contribución en ambos lados del intervalo -- (vote weight)
    % son matrices del mismo tamaño de la celda
    rContribs = (angs-lInt_centers)/anchoInt;
    lContribs = 1 - rContribs;
    lContribs = mags.*lContribs;
    rContribs = mags.*rContribs;
    
    % contribuciones al histograma intervalo por intervalo
    for bin=1:bins
        % Pixeles que contribuyen al intervalo izq.
        pixLeft = (lIndices == bin);
        h(bin) = h(bin) + sum(lContribs(pixLeft));
        
        % Pixeles que contribuyen al intervalo der.
        pixRight = (rIndices == bin);
        h(bin) = h(bin) + sum(rContribs(pixRight));
    end

    % Concatenar el histograma a la matriz de histogramas
    rowOff = floor(counter/numHCells + 1);
    colOff = mod(counter-1,numHCells)+1;
    histogramas(rowOff,colOff,:) = h(1,:);

end

%% Normalizar bloques
hist_size = blSz*blSz*bins;
col = 1;
row = 1;
H = [];

%% Seccionar la matriz de histogramas en bloques ---- (this code assumes an 50% of overlap as desp is hard coded as 1)
while row <= numVCells-blSz+1
    while col <= numHCells-blSz+1
        
        % Los histogramas en un bloque:
        blockHists = ...
            histogramas(row:row+blSz-1, col:col+blSz-1, :);
        
        % La magnitud de los histogramas en el bloque
        %(Para normalizar)
        magnitude = norm(blockHists(:),2);
    
        % Normalizar los valores en el histograma
        normalized = blockHists / (magnitude + 0.0001);

        offset = (row-1)*(numHCells-blSz+1)+col;
        ini = (offset-1)*hist_size+1;
        fin = offset*hist_size;

        H(ini:fin,1) = normalized(:);

        col = col+1;
    end
    row = row+1;
    col = 1;
end
