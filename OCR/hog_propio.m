function [ feature] = hog_propio( im )
%HOG Summary of this function goes here
%Detailed explanation goes here
imshow(im)
r=size(im,1);
c=size(im,2);
if size(im,3)==3
  im=rgb2gray(im);
end
%im=double(im);
hx = [-1,0,1];
hy = [1;0;-1];
grad_xr = imfilter((im),hx,'conv');
grad_yu = imfilter((im),hy,'conv');
teta=atan2(double(grad_yu),double(grad_xr));
magnit=sqrt(double((grad_yu.^2)+(grad_xr.^2)));
angle=imadd(teta,90); %(0,180)
feature=[]
%itération par block
for i=0 : r/8-2
  for j=0:c/8-2
      mag_Block=magnit(8*i+1:8*i+16, 8*j+1:8*j+16);
      angle_Block=angle(8*i+1:8*i+16,8*j+1:8*j+16);
      block_feature=[];
      %itérarions par cell
      for x=0:1
          for y=0:1
              mag_Cell=mag_Block(8*x+1:8*x+8,8*y+1:8*y+8);
              angle_Cell=angle_Block(8*x+1:8*x+8,8*y+1:8*y+8);
               % hold on
               % quiver(x,y, angle_Cell(x+1),angle_Cell(y+1))
                H=zeros(1,9)
                %itérations par pixels dans la même cellule
                for p=1:8
                    for q=1:8
                        angle_Pixel=angle_Cell(p,q);
                        if angle_Pixel>0 && angle_Pixel<=10
                            H(1)=H(1)+ mag_Cell(p,q)*(angle_Pixel+10)/20;
                            H(9)=H(9)+ mag_Cell(p,q)*(10-angle_Pixel)/20;
                        elseif angle_Pixel>10 && angle_Pixel<=30
                            H(1)=H(1)+ mag_Cell(p,q)*(30-angle_Pixel)/20;
                            H(2)=H(2)+ mag_Cell(p,q)*(angle_Pixel-10)/20;
                        elseif angle_Pixel>30 && angle_Pixel<=50
                           H(2)=H(2)+ mag_Cell(p,q)*(50-angle_Pixel)/20;                 
                           H(3)=H(3)+ mag_Cell(p,q)*(angle_Pixel-30)/20;
                        elseif angle_Pixel>50 && angle_Pixel<=70
                           H(3)=H(3)+ mag_Cell(p,q)*(70-angle_Pixel)/20;
                           H(4)=H(4)+ mag_Cell(p,q)*(angle_Pixel-50)/20;
                        elseif angle_Pixel>70 && angle_Pixel<=90
                           H(4)=H(4)+ mag_Cell(p,q)*(90-angle_Pixel)/20;
                           H(5)=H(5)+ mag_Cell(p,q)*(angle_Pixel-70)/20;    
                        elseif angle_Pixel>90 && angle_Pixel<=110
                           H(5)=H(5)+ mag_Cell(p,q)*(110-angle_Pixel)/20;
                           H(6)=H(6)+ mag_Cell(p,q)*(angle_Pixel-90)/20;
                        elseif angle_Pixel>110 && angle_Pixel<=130
                           H(6)=H(6)+ mag_Cell(p,q)*(130-angle_Pixel)/20;
                           H(7)=H(7)+ mag_Cell(p,q)*(angle_Pixel-110)/20;
                        elseif angle_Pixel>130 && angle_Pixel<=150
                           H(7)=H(7)+ mag_Cell(p,q)*(150-angle_Pixel)/20;
                           H(8)=H(8)+ mag_Cell(p,q)*(angle_Pixel-130)/20;
                        elseif angle_Pixel>150 && angle_Pixel<=170
                           H(8)=H(8)+ mag_Cell(p,q)*(170-angle_Pixel)/20;
                           H(9)=H(9)+ mag_Cell(p,q)*(angle_Pixel-150)/20;
                        end
                    end
                end
                block_feature=[ block_feature H];
            end
        end
         block_feature= sqrt(block_feature./(norm(block_feature))^2+0.001);
         feature=[ feature block_feature ];
    end
end
end