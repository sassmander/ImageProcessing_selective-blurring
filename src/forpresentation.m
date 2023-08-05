%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENG EC 520 (Konrad) Spring 2023
% Final Project
% Sally Shin salshin@bu.edu
% Ysatis Tagle ytagle@bu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To run the code, run each section after each other (or click RUN) 
% Comments help guide where values can be changed

% Values that can be changed without issue:
% 1. Image titles
% 2. Threshold
% 3. Division bins for histogram vector (or make your own)
% 4. blurarea: 'b' for background blurring, 'f' for foreground blurring
% 5. blur_radius_once = higher the value, higher the blur effect on onetime
% blurring
% 6. bluroption: 'o' for onetime blurring, 'g' for gradient blurring

clear;
clc;

%% Image Imports

% Replace image files here to work with different images
imageRGB = imread('ysatisRGB_Color.png');
imageDepth = imread('ysatisDepth_Depth.png');

figure(1)
imshow(imageRGB)

figure(2)
imshow(imageDepth)

%% Hole filling

imageDepth_gray = rgb2gray(imageDepth); 
filledDepth_og = holefilling(imageDepth_gray);
figure(3)
imshow(filledDepth_og, [])

figure(4)
histogram(filledDepth_og)
title('Histogram bins of Depth Map Values')

%% Image Registration between RGB and depth map

% In the pop-up, select points of similarities
[mp, fp] = cpselect(imageDepth, imageRGB, Wait=true);
t = fitgeotform2d(mp, fp, "projective")

Rfixed = imref2d(size(imageRGB));
registeredImage = imwarp(imageDepth, t, OutputView=Rfixed);

figure(5)
imshowpair(imageRGB, registeredImage, "blend")

figure(6)
imshow(registeredImage)


%% Image Registration between depth maps

% In the pop-up, select points of similarities
[mp, fp] = cpselect(filledDepth_og, registeredImageg, Wait=true);
t = fitgeotform2d(mp, fp, "projective")

Rfixed = imref2d(size(registeredImageg));
registeredImage_holefill = imwarp(filledDepth_og, t, OutputView=Rfixed);

figure(7)
imshowpair(registeredImageg, registeredImage_holefill, "blend")
figure(8)
histogram(registeredImage_holefill)
title('Histogram bins of Depth Map Values')

figure(9)
imshow(registeredImage_holefill)
%% Segmentation with 1 Threshold at 128
% Change threshold here to change segmentation images
threshold = 128;

bwregisteredImage = im2gray(registeredImage_holefill);

thresholdImageForeground = bwregisteredImage < threshold;
thresholdImageForeground = uint8(thresholdImageForeground);

thresholdImageBackground = bwregisteredImage >= threshold;
thresholdImageBackground = uint8(thresholdImageBackground);

thresholdImageRGB(:,:,1) = thresholdImageForeground.*imageRGB(:,:,1);
thresholdImageRGB(:,:,2) = thresholdImageForeground.*imageRGB(:,:,2);
thresholdImageRGB(:,:,3) = thresholdImageForeground.*imageRGB(:,:,3);
figure(10)
imshow(thresholdImageRGB)

thresholdImageRGB_BG(:,:,1) = thresholdImageBackground.*imageRGB(:,:,1);
thresholdImageRGB_BG(:,:,2) = thresholdImageBackground.*imageRGB(:,:,2);
thresholdImageRGB_BG(:,:,3) = thresholdImageBackground.*imageRGB(:,:,3);
figure(11)
imshow(thresholdImageRGB_BG)

%% Matting - Convert to 1s and 0s
[r c] = size(thresholdImageForeground);
zeroedthresholdImageFore = zeros(r,c);
for i=1:r
    for j=1:c
        if thresholdImageRGB(i,j) > 0
            zeroedthresholdImageFore(i,j) = 1;
        end
    end
end
%% Matting - Apply Gaussian filter
blurthresholdImageFore = imgaussfilt(zeroedthresholdImageFore, 4);
blurthresholdImageBkg = imcomplement(blurthresholdImageFore);
figure(12)
imshow(blurthresholdImageFore)
figure(13)
imshow(blurthresholdImageBkg)
checkcomplement = blurthresholdImageFore+blurthresholdImageBkg;
min(min(checkcomplement))
max(max(checkcomplement))
%% Blurring 
% Make vector of histogram bins for the depth maps
division = 40; %bins

% BW is used for foreground blurring (blacker -> closer)
bw = threshold:-division:0; % going backwards in hist

% FW is used for background blurring (whiter -> farther)
fw = threshold:division:255; % going forwards in hist

% Adds end values 255 and 0 to each
if fw(end) ~= 255
    fw(end+1) = 255;
end

if bw(end) ~= 0
    bw(end+1) = 0;
end

% Blur choice 'f' blurs the foreground 
% Blur choice 'b' blurs the background 
blurarea = 'b';
%blurarea = 'f';

% Blur option 'g' implements gradient depth sweep (multiple blurs)
% Blur option 'o' implements blurring once in the blur area
%bluroption = 'o';
blur_radius_once = 4;
bluroption = 'g';


doubleimageRGB = im2double(imageRGB);
[rzero, czero] = size(zeroedthresholdImageFore);
mask = zeros(rzero,czero);
blurmask = zeros(rzero,czero,3);
img_blur = doubleimageRGB;

%% Gradient depth sweep implementation
% Custom fw with chosen threshold 
fw = [128, 200, 220, 240, 245, 250, 255];
bw = [128, 90, 85, 80, 75, 50, 0];
if isequal(bluroption, 'g')
    if isequal(blurarea,'b')
        for i = 2:length(fw)
            mask = zeros(rzero,czero);
            for row=1:rzero
                for col=1:czero
                    if ((registeredImage_holefill(row,col)>fw(i-1))&&(registeredImage_holefill(row,col) <= fw(i))&&(blurthresholdImageBkg(row,col)>0))
                        mask(row,col) = 1;
                    end
                end
            end
            mask = imgaussfilt(mask, 10);
            if i == 2
                blur_radius = 1;
                h = fspecial('gaussian', [blur_radius*2+1, blur_radius*2+1], blur_radius);
                for j = 1:size(doubleimageRGB, 3)
                    img_blur(:, :, j) = doubleimageRGB(:, :, j) .* (1-mask) + imfilter(doubleimageRGB(:, :, j), h) .* mask;
                    figure(i)
                    imshow(img_blur)
                end
            elseif i > 2
                blur_radius = i*5;
                h = fspecial('gaussian', [blur_radius*2+1, blur_radius*2+1], blur_radius);
                for j = 1:size(doubleimageRGB, 3)
                    img_blur(:, :, j) = img_blur(:, :, j) .* (1-mask) + imfilter(img_blur(:, :, j), h) .* mask;
                    figure(i)
                    imshow(img_blur)
                end
                
            end
        end
    end
    if isequal(blurarea,'f')
        for i = 2:length(bw)
            mask = zeros(rzero,czero);
            for row=1:rzero
                for col=1:czero
                    if ((registeredImage_holefill(row,col)<=bw(i-1))&&(registeredImage_holefill(row,col) >= bw(i))&&(blurthresholdImageFore(row,col)>0))
                        mask(row,col) = 1;
                    end
                end
            end
            mask = imgaussfilt(mask, 1);
            if i == 2
                blur_radius = 1;
                h = fspecial('gaussian', [blur_radius*2+1, blur_radius*2+1], blur_radius);
                for j = 1:size(doubleimageRGB, 3)
                    img_blur(:, :, j) = doubleimageRGB(:, :, j) .* (1-mask) + imfilter(doubleimageRGB(:, :, j), h) .* mask;
                    figure(i)
                    imshow(img_blur)
                end
            elseif i > 2
                blur_radius = i*5;
                h = fspecial('gaussian', [blur_radius*2+1, blur_radius*2+1], blur_radius);
                for j = 1:size(doubleimageRGB, 3)
                    img_blur(:, :, j) = img_blur(:, :, j) .* (1-mask) + imfilter(img_blur(:, :, j), h) .* mask;
                    figure(i)
                    imshow(img_blur)
                end
            end
        end
    end
elseif isequal(bluroption, 'o')
    if isequal(blurarea, 'b')
        h = fspecial('gaussian', [blur_radius_once*2+1, blur_radius_once*2+1], blur_radius_once);
        for j = 1:size(doubleimageRGB, 3)
            img_blur(:, :, j) = doubleimageRGB(:, :, j) .* (1-blurthresholdImageBkg) + imfilter(doubleimageRGB(:, :, j), h) .* blurthresholdImageBkg;
        end
    elseif isequal(blurarea, 'f')
        h = fspecial('gaussian', [blur_radius_once*2+1, blur_radius_once*2+1], blur_radius_once);
        for j = 1:size(doubleimageRGB, 3)
            img_blur(:, :, j) = doubleimageRGB(:, :, j) .* (1-blurthresholdImageFore) + imfilter(doubleimageRGB(:, :, j), h) .* blurthresholdImageFore;
        end
    end
end

figure(14)
imshow(img_blur)


