addpath('C:\Users\USER\Documents\Uni\Imágenes\Corte II\Taller 4\IMGS\binary');

i1=imread('2.gif');i1=i1(:,:,1);
i1=(zeros(256));
% [c1,n]=imhist(i1);
[features1, visualization] = extractHOGFeatures(i1,'CellSize',[16 16]);

features1=features1/size(i1,1)/size(i1,2);



i2=imread('9.gif');i2=i2(:,:,1);
i2 = imresize(i2,[256 256]);
i2=(ones(256));
i2(1:4,:)=0;
% [c2,n2]=imhist(i2);


%Normalizar

[features2, visualization2] = extractHOGFeatures(i2,'CellSize',[16 16]);
features2=features2/size(i2,1)/size(i2,2);

d = pdist2(features1,features2);