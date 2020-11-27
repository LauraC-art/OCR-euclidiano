function celdas=coordenadas(I,wx_sz, wy_sz) %imagen, celdas [8 8]
%%Seccionar la imagen
[r,c]=size(I);

% Número de segmentos de la imagen
segmentosX = floor(c/wx_sz);  %24/8 = 3
segmentosY = floor(r/wy_sz);  %42/8 = 5

% De forma vectorial
% xs_ini(1:3) = 8*( (1:3)-1 ) + 1
% xs_ini(1:1) = 8* ( 1-1 ) + 1
xs_ini(1:segmentosX) = wx_sz*((1:segmentosX)-1)+1;     % x_ini
% disp(xs_ini);

% xs_fin (1:3) = 8* min( (1:3),c ) ~mínimo valor de (1:segmentosX) en cada
% una de sus columnas
% (1:segmentosX)=[1 2 3] -> mínimo en cada columna: 1 2 3
xs_fin(1:segmentosX) = wx_sz*min((1:segmentosX),c);    % x_fin compara 
% disp(min((1:segmentosX)));

ys_ini(1:segmentosY) = wy_sz*((1:segmentosY)-1)+1;     % y_ini
ys_fin(1:segmentosY) = wy_sz*min((1:segmentosY),r);    % y_fin

[X_ini,Y_ini] = meshgrid(ys_ini,xs_ini);
[X_fin,Y_fin] = meshgrid(ys_fin,xs_fin);
celdas = [Y_ini(:),Y_fin(:),X_ini(:),X_fin(:)]';

% %%Lo mismo pero no vectorizado, ayudó a la comprensión
% windows = zeros(4,y_segs*x_segs); %bloques?
% for i=1:x_segs      %Recorrer la imagen por celdas horizontalmente (3
%     for j=1:y_segs  %Recorrer la imagen por celdas verticalmente (5
%  
%         % windows coordinates calculations
%         % Coordenadas de la celdas
%         x_ini = wx_size*(i-1)+1;    % coord_seg_1 = 8*(primer_seg_x-1)+1, 1
%      
%         x_fin = min(wx_size*i,c);   % valor mínimo de 8*(primer_seg_x)
%         y_ini = wy_size*(j-1)+1;
%         y_fin = min(wy_size*j, r);
%         
%         % saving coordinates in the 'windows' array
%         col = (j-1)*x_segs+i;
%         windows(1,col) = x_ini;
%         windows(2,col) = x_fin;
%         windows(3,col) = y_ini;
%         windows(4,col) = y_fin;
%     end
% end