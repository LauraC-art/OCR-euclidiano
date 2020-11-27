i1=(zeros(256));
[features1, visualization] = extractHOGFeatures(i1,'CellSize',[16 16]);

%features1=features1/size(i1,1)/size(i1,2);

i2=(ones(256));
%i2(1:4,:)=0;


[features2, visualization2] = extractHOGFeatures(i2,'CellSize',[16 16]);


d = pdist2(features1,features2);

figure;
subplot(2,1,1);imshow(i1), title('Matriz de 0');
subplot(2,1,2);imshow(i2), title('Matriz de 1');

figure;
subplot(2,1,1);plot(visualization), title('Matriz de 0');
subplot(2,1,2);plot(visualization2), title('Matriz de 1');