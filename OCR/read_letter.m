function letter=read_letter(imagn,num_letras)

load tempHog
global tempHog

%Variables auxiliares
daux=1000;
letra=0;

%Clasificación usando distancia euclidiana
for n=1:num_letras   
    d = pdist2(imagn,tempHog{1,n});    
    if d<daux
     daux=d;
     letra=n;     
    end
end

%Mostrar letra identificada una a una
%figure;
%imshow(~(templates{1,letra}))

%Esto es para el bloc de notas:
% %*-*-*-*-*-*-*-*-*-*-*-*-*-
if letra==1
    letter='A';
elseif letra==2
    letter='B';
elseif letra==3
    letter='C';
elseif letra==4
    letter='D';
elseif letra==5
    letter='E';
elseif letra==6
    letter='F';
elseif letra==7
    letter='G';
elseif letra==8
    letter='H';
elseif letra==9
    letter='I';
elseif letra==10
    letter='J';
elseif letra==11
    letter='K';
elseif letra==12
    letter='L';
elseif letra==13
    letter='M';
elseif letra==14
    letter='N';
elseif letra==15
    letter='O';
elseif letra==16
    letter='P';
elseif letra==17
    letter='Q';
elseif letra==18
    letter='R';
elseif letra==19
    letter='S';
elseif letra==20
    letter='T';
elseif letra==21
    letter='U';
elseif letra==22
    letter='V';
elseif letra==23
    letter='W';
elseif letra==24
    letter='X';
elseif letra==25
    letter='Y';
elseif letra==26
    letter='Z';
    %*-*-*-*-*
elseif letra==27
    letter='1';
elseif letra==28
    letter='2';
elseif letra==29
    letter='3';
elseif letra==30
    letter='4';
elseif letra==31
    letter='5';
elseif letra==32
    letter='6';
elseif letra==33
    letter='7';
elseif letra==34
    letter='8';
elseif letra==35
    letter='9';
else
    letter='0';
end
