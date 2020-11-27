function [angs,mags] = gradiente(I)

%%Tamaño de la imagen
[m,n] = size(I);
    % Añadir un borde en caso de que la imagen tenga un contorno  
    % Mejorar la imagen
    I = imadjust(I);
    % Bordes de la imagen
    imagen = ones(m+2,n+2);
    imagen(2:1+m,2:1+n) = I(:,:);
    
    % Gradiente de la imagen
    [Gx,Gy]=imgradientxy(imagen);
    
    %Obtener dirección y magnitud
    angs = atan2(Gy,Gx);
    mags = abs(Gy) + abs(Gx);

% Dejar los ángulos en un rango entre 0 y 180
angs(angs(:)<0) = angs(angs(:)<0)+pi;