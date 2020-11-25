function celdas=coordenadas(I,wx_sz, wy_sz)
%%Seccionar la imagen
[r,c]=size(I);

segmentosX = floor(c/wx_sz);
segmentosY = floor(r/wy_sz);

% De forma vectorial
xs_ini(1:segmentosX) = wx_sz*((1:segmentosX)-1)+1;     % x_ini
xs_fin(1:segmentosX) = wx_sz*min((1:segmentosX),c);    % x_fin
ys_ini(1:segmentosY) = wy_sz*((1:segmentosY)-1)+1;     % y_ini
ys_fin(1:segmentosY) = wy_sz*min((1:segmentosY),r);    % y_fin

[X_ini,Y_ini] = meshgrid(ys_ini,xs_ini);
[X_fin,Y_fin] = meshgrid(ys_fin,xs_fin);
celdas = [Y_ini(:),Y_fin(:),X_ini(:),X_fin(:)]';

% %%Lo mismo pero no vectorizado, ayudó a la comprensión
% windows = zeros(4,y_segs*x_segs);
% for i=1:x_segs
%     for j=1:y_segs
%         
%         % windows coordinates calculations
%         x_ini = wx_size*(i-1)+1;
%         x_fin = min(wx_size*i,c);
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