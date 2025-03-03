%% reading the image
 
A = imread('angio_n.bmp');
Afilt = medfilt2(medfilt2(A,[7,7]));


sobeldi = [-1,-1,0;-1,0,1;0,1,2];
Agradientdi = imfilter(Afilt,sobeldi, 'conv');


lapl = [-1 -1 -1; -1 8 -1; -1 -1 -1];
resp = imfilter((Afilt+ Agradientdi), lapl, 'conv');
resp = imfilter((Afilt+ Agradientdi+ resp), lapl, 'conv');

avg = [1/9 1/9 1/9;1/9 1/9 1/9;1/9 1/9 1/9];
Afilt = imfilter(Agradientdi + Afilt - resp, avg, 'conv');

%Agradientdi = imopen(Agradientdi,filler3);
figure(1);
imshow(Afilt);

filler3 = strel('disk',6);
Afilt = imclose(Afilt,filler3);

figure(2);
imshow(Afilt);

figure(3)
edges = edge(Afilt,'canny',0.3);
imshow(edges);




%% automated rotation of image with filtering

%filtering part
G = imread('angio_n.bmp');
G = medfilt2(medfilt2(G));
filler = strel('disk',4);
G = imclose(G,filler);
G = imopen(G,filler);


[BW] = edge(G,'canny',0.3);
[~,gdir]=imgradient(G);
[m,n]=size(G);  
for i=1:m-1
    for j=1:n-1
        if (BW(i,j)==0)
           gdir(i,j)=0;           
        end
    end
end


avgTheta = 0;
numOfpts = 0;
for i = 100:m-7
    for j = 7:n-7
        if (gdir(i,j) ~= 0)
            numOfpts = numOfpts + 1;
            avgTheta = avgTheta + gdir(i,j);
        end
    end
end

avgTheta = avgTheta/(numOfpts);




rotI = imrotate(G,avgTheta,'crop');


figure(4);
imshow(rotI);
figure(5);
imshow(rotI((112:300),:));
%now user chooses how to crop the image
figure(6);
binaryImage = imbinarize(rotI);
binaryImage = binaryImage((112:300),:);
imshow(binaryImage);

%horizontal detector

[m2,n2] = size(binaryImage);
maxWidth = 0;
minWidth = n2;

for i = 1:m2
    tempWidth = 0;
    for j = 1:n2
        if binaryImage(i,j) == 1
            tempWidth = tempWidth + 1;
        end
        if tempWidth > maxWidth
            maxWidth = tempWidth;
        end
    end
    if tempWidth < minWidth
        minWidth = tempWidth;
    end
end
%percent stenosis = [1 − ((Dstenosis)/(Dnormal))] × 100,


percentSten = (1-(minWidth)/(maxWidth))*100;