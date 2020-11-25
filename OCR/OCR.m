%OCR empleando histograma de gradientes
addpath('C:\Users\USER\Documents\Uni\Imágenes\OCR\OCR HOG\imgs')

warning off %#ok<WNOFF>
%La imagen de entrada
imagen=imread('TEST_3.jpg');
imshow(imagen);
title('Imagen original')
if size(imagen,3)>1
    imagen=rgb2gray(imagen);
end
%Binarizar
threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);

%Quitar objetos con menos de 30 pixeles
imagen = bwareaopen(imagen,30);
%----------------------------------------
%Un array para guardar la palabra
word=[ ];

imagenSegmentada=imagen;
%%
%Para guardar en txt
%Opens text.txt as file for write
fid = fopen('text.txt', 'wt');
%----------------------------------------
%%
%Los templates de los dataset de base
load templates
global templates
%Número de letras en el template
num_letras=size(templates,2);
%%
while 1
    %Sacar los renglones de la imagen
    [imgRenglon, imagenSegmentada]=lines(imagenSegmentada);
    images=imgRenglon;
    %Los renglones:
    %imshow(imgRenglon);pause(0.5)  
        
    %Poner un label a cada región detectada
    [Labels, numRegiones] = bwlabel(images);
    for n=1:numRegiones
        [r,c] = find(Labels==n);
        %Solo extraer la letra
        n1=images(min(r):max(r),min(c):max(c));  
        %Ajustar tamaño (mismo tamaño que la del dataset base)
        img_r=imresize(n1,[42 24]);
        %Letras segmentadas una por una
        %imshow(img_r);pause(0.5)
        
        %Extraer las características del HOG
        %img_r=matlab_HOG(img_r);
        img_r=hog_propio(img_r);     
        %Comparar histogramas con distancia euclidiana
        letter=read_letter(img_r, num_letras);
        
        %Esto es pa lo del bloc de notas: Letter concatenation        
        word=[word letter];
    end
    
    %eso es pa escribir:
    %fprintf(fid,'%s\n',lower(word));%Write 'word' in text file (lower)
    fprintf(fid,'%s\n',word);%Write 'word' in text file (upper)
    
    %Clear 'word' variable
    word=[ ];
    
    %Salir del loop cuando ya termina la imagen
    if isempty(imagenSegmentada)%See variable 're' in Fcn 'lines'
        break
    end    
end
%Pa escribir en el bloc de notas
fclose(fid);
%Open 'text.txt' file
winopen('text.txt')
fprintf('For more information, visit: <a href= "http://www.matpic.com">www.matpic.com </a> \n')
clear all