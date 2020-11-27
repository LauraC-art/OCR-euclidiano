function H = hog_propio_2(I)
%%

% Definir tamaños
celdaSz=8;  %Celdas
blSz=2;     %Bloques

% Del histograma
bins=9;                  % Intervalos, los ángulos (0:180). Los ángulos
                         % y sus negativos se representan con los mismos
                         % números
                       
tAngs = 180.0;           %El máximo ángulo para los bins del histograma
anchoInt = tAngs/bins;   %Intervalos de ancho 20°

%% Para mapear los centros de los intervalos
mCentrInt = (anchoInt/2:anchoInt:tAngs)';   % 0 a 20, esto toma el centro = 10
                                            % 20 a 40, centro = 30, etc...
%% Calcular el gradiente a toda la imagen
% Dirección y magnitud
[angsGrad, magsGrad] = gradiente(I);

%% Seccionar imagen en celdas 
% Recupera las coordenadas de cada celda (son 3*5 celdas)
coordCeldas = coordenadas(angsGrad,celdaSz,celdaSz);

%% Inicializar matriz de histogramas
% Celdas horizontales y verticales
[he,wi] = size(I(:,:,1));
numVCells = floor(he/celdaSz); % 5
numHCells = floor(wi/celdaSz); % 3

% Matriz de los histogramas por celdas [8 8] en la imagen
histogramas = zeros(numVCells,numHCells,bins);

%% Histograma de todas las celdas en la imagen
for counter=1:size(coordCeldas,2) %1:15 por las columnas del array de celdas de la imagen en horizontal
    
    % Inicializar histograma de la celda [8 8] actual
    h = zeros(1,bins);   %h es el histograma de la celda actual
                         % (1:9) # intervalos    
    % Coordenadas de las celdas
    xMin = coordCeldas(1,counter);
    xMax = coordCeldas(2,counter);
    yMin = coordCeldas(3,counter);
    yMax = coordCeldas(4,counter);

    % Direcciones y magnitudes para los pixeles
    % en las celdas
    % angsGrad y magsGrad es lo que obtuvimos del gradiente
    
    % angs = ángulos de la imagen de acuerdo a las celdas
    angs = angsGrad(yMin:yMax,xMin:xMax);   % Esto de yMin, etc, son las coordenadas en las celdas
                                            % Recuperar los ángulos de cada
                                            % celda indexando
    
    angs = angs.*180/pi;                    % Pasar a grados
    mags = magsGrad(yMin:yMax,xMin:xMax);   % Esto de yMin, etc, son las coordenadas en las celdas
                                            % Recuperar la magnitud de cada
                                            % celda indexando

    
    % Indices de los intervalos izquierdo y derecho que limitan
    % (inicio y fin del intervalo)
    lIndices = round(angs/anchoInt);    % Índices izquierdos
                                        % Coge los ángulos de la celda y
                                        % los divide sobre el ancho del
                                        % intervalo (20).
                                        
% Para el intervalo 135 el límite inferior es 7 (se encuentra en
% el intervalo 7) y su límite derecho sería 8
    rIndices = lIndices+1;

    % Contribuciones en el histograma
    lIndices(lIndices==0) = 9;          % Donde los índices límite izquierdos
                                        % sean = 0, se asignará su límite
                                        % al bin 9.
                                        % Por ejemplo para un ángulo de 0,
                                        % sú límite izquierdo (en los bins)
                                        % es el noveno.
                                        
    rIndices(rIndices==10) = 1;         % Por ejemplo un ángulo de 180, tendrá
                                        % límite derecho con el bin 0, por
                                        % lo que en este apartado solo se
                                        % reasigna esa "posición" ya que
                                        % son 9 bins únicamente en el
                                        % histograma
    
    % Aquí es solo recuperar el valor central del intervalo correspondiente
    % para los índices de límite izquierdos.
    lInt_centers = mCentrInt(lIndices);     % Por ejemplo para el ángulo de 135
                                            % el límite izquierdo del intervalo
                                            % (lIndices) es 7. Su bin
                                            % central izquierdo correspondiente
                                            % es 130, pues mCentrInt(7) = 130
        angs(angs < lInt_centers) = ...         
        tAngs + angs(angs < lInt_centers);

    % angs = ángulos en cada celda.  donde angs < bin central izquierdo
    % angs = 180 + ángulos en la celda menores a los centros izquierdos del
    % intervalo.
    % Por ejemplo ángulo = 0 es < que su intervalo central izquierdo (170)
    % - recordar que su valor limítrofe izq. fue ajustado a 9 en la línea 75 -
    % tomará un valor = 180, pues entraría en esa clasificación y es
    % necesario ajustar dicho valor del ángulo
    
    
    % Contribución en ambos lados del intervalo -- (vote weight)
    % son matrices del mismo tamaño de la celda
    rContribs = (angs-lInt_centers)/anchoInt;   %Contribución al bin de su derecha
                                                % Ej. (135-130)/20
    lContribs = 1 - rContribs;     % Contribución al bin de su izquierda
    lContribs = mags.*lContribs;   % Se asigna la proporción de magnitud de
                                   % la celda al bin izquierdo.
    
	rContribs = mags.*rContribs;   % Se asigna la proporción de magnitud de
                                   % la celda al bin derecho.
    
    % Contribuciones al histograma intervalo por intervalo
    for bin=1:bins         % Contador 1:9
        
        % Cantidad de pixeles que contribuyen al bin izq.
        pixLeft = (lIndices == bin);    %lIndices indica el # de bin (1:9)
        % El vector histograma en la posición del bin tomará la cantidad
        % de contribuciones a la izquierda en ese bin.
        h(bin) = h(bin) + sum(lContribs(pixLeft));
        
        % Cantidad de pixeles que contribuyen al intervalo derecho
        pixRight = (rIndices == bin);   % elementos de rIndices = al # del bin actual
        h(bin) = h(bin) + sum(rContribs(pixRight)); %sumar contribuciones
    end

    % Concatenar el histograma en la matriz de histogramas
    rowOff = floor(counter/numHCells + 1);  % celdaActual/(celdasX + 1)
                                            % Ej. última celda = 15
                                            % rowOff = floor(15/3)+1 = 6
                                            % + 1 porque digamos counter=1
                                            % y floor(1/3) = 0, necesitamos
                                            % un index > 1
                                            
    colOff = mod(counter-1,numHCells)+1;    % [1 1]
    
    histogramas(rowOff,colOff,:) = h(1,:);  % histogramas(filas, cols, bins)
                                            % h es histograma actual
                                            % histogramas son los histogramas
                                            % de todas las celdas (8x8) de la
                                            % imagen
end
%% Normalizar bloques
hist_size = blSz*blSz*bins; %Tamaño del histograma por bloques = 2*2*9 = 36
col = 1;
row = 1;
H = []; %Inicializar histograma final

%% Seccionar la matriz de histogramas en bloques de la imagen
% Parecido a "ventanear"
while row <= numVCells-blSz+1   % filas <= 5 - 2 + 1 <= 4 (verticalmente)
    while col <= numHCells-blSz+1   %cols <= 3 - 2 + 1 <= 2 (horizontalmente)
        
        % Los histogramas en un bloque:
        blockHists = ...
            histogramas(row:row+blSz-1, col:col+blSz-1, :);
        % Ej. primer bloque 1, histogramas((1:2), (1:2))
        
        % Normalizar la magnitud de los histogramas en el bloque
        magnitude = norm(blockHists(:),2);  % Magnitud del vector
        % Histograma normalizado
        normalized = blockHists / (magnitude + 0.0001);

        %
        offset = (row-1)*(numHCells-blSz+1)+col;
        % disp(offset);
        % Ej. row=1 y col=1, offset=(1-1)*(3-2+1)+1= 1
        % Ej. row=1 y col=2, offset=(1-1)*(3-2+1)+ 2 = 2
        % Ej. row=2 y col=1, offset=(2-1)*(3-2+1)+1= 3
        
        ini = (offset-1)*hist_size+1;
        fin = offset*hist_size;

        H(ini:fin,1) = normalized(:);

        col = col+1; % Se incrementa con paso 1
    end
    row = row+1;    % Se incrementa con paso 1
    col = 1;        % Reiniciar col para pasar a siguiente bloque de filas
end
