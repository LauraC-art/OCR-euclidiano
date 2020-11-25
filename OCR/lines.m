function [fl re]=lines(im_texto)

nFilas=size(im_texto,1);

for s=1:nFilas %Recorrer todas las filas
    if sum(im_texto(s,:))==0 %Si la sumatoria en esa fila de la imagen es 0
        nm=im_texto(1:s-1, :); % First line matrix
        rm=im_texto(s:end, :);% Remain line matrix
        fl = clip(nm);
        re=clip(rm);
        %*-*-*Uncomment lines below to see the result*-*-*-*-
        %         subplot(2,1,1);imshow(fl);
        %         subplot(2,1,2);imshow(re);
        break
    else
        fl=im_texto;%Only one line.
        re=[ ];
    end
end

function img_out=clip(img_in)
%Hallar índices de la imagen completa (párrafo)
[f,c]=find(img_in);
%
img_out=img_in(min(f):max(f),min(c):max(c));%Corta la imagen