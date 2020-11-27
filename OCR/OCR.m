%OCR empleando histograma de gradientes

%La imagen de entrada
imagen=imread('TEST_8.jpg');
imshow(imagen);
title('Imagen original')
if size(imagen,3)>1
    imagen=rgb2gray(imagen);
end


%Binarizar
threshold = graythresh(imagen);
imagen =~im2bw(imagen, threshold);

%----------------------------------------
%Un array para guardar la palabra
%y mostrar en el Bloc de Notas
word=[ ];

imagenN=imagen;

%Para guardar en txt
fid = fopen('text.txt', 'wt');
%----------------------------------------

%Los templates de los dataset de base
load templates
global templates
%N�mero de letras en el template
num_letras=size(templates,2);

while 1
    %Sacar los renglones de la imagen
    [imgRenglon, imagenN]=lines(imagenN);
    images=imgRenglon;
    
    
    %Los renglones:
%     figure;
%     imshow(imgRenglon);pause(0.5)  
    % Aqu� ya obtuvimos el rengl�n    
    % Poner un label a cada regi�n
    
    
    [Labels, numRegiones] = bwlabel(images);
    
    %N�meros de regiones en la imagen
    for n=1:numRegiones
        [r,c] = find(Labels==n);%guardar en una matriz los �ndices de la imagen con etiquetas
                                % donde la regi�n sea igual al valor de n.
                                % n=1, se coge toda la regi�n etiquetada
                                % con 1, cuando n=2 lo mismo y as�        
        % Solo extraer la letra
        % Este funciona como clip
        % Indexar
        n1=images(min(r):max(r),min(c):max(c));  
        
        % Ajustar tama�o (mismo tama�o que la del dataset base)
        % Tiene que ser del mismo tama�o del dataset porque pdist2
        
        img_r=imresize(n1,[42 24]);
        
        %Letras segmentadas una por una
        %figure,imshow(img_r);%pause(0.5)
        
        %Extraer las caracter�sticas del HOG
        %img_r=matlab_HOG(img_r);
        img_r=hog_propio_2(double(img_r))';     
        %Comparar histogramas con distancia euclidiana
        letter=read_letter(img_r, num_letras);
        
        %Esto es para armar el bloc de notas: concatenar letras   
        % primera vez: word=[letra_1]
        % llega otra letra: word=[word letra_2]
        word=[word letter];
    end
    
    %eso es pa escribir:
    fprintf(fid,'%s\n',word);%
    
    %limpiar la variable antes de escribir
    word=[ ];
    
    %Salir del loop cuando ya termina la imagen
    if isempty(imagenN)%Si no hay m�s renglones (re de l�neas)
        break
    end    
end
%Para escribir en el bloc de notas
fclose(fid);
%Abrir el archivo de texto
winopen('text.txt')