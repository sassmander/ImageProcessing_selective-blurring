function filled = holefilling(x)
    arguments
        x (:,:,:) {mustBeNumeric, mustBeNonnegative} %depth image
    end
    grayx = im2gray(x);
    grayx = imfill(grayx);
    [holex,holey] = find(~grayx);

    for i = 1:length(holex)
        if holex(i) == 1
            color = 255;
        else
            color = grayx(holex(i)-1, holey(i));
        end
        grayx(holex(i),holey(i)) = color; 
    end
    grayx(1,1) = 0; % this is done so that the color range is 0 to 255
    filled = grayx;
end
