## Selective depth-based blurring using RGB and depth map images

### Aim

The aim of this codebase was to implement from scratch a selective blurring of images using depth-based information from images captured with Intel RealSense D435. While the aim is to achieve an effect similar to commonly-seen Portrait mode, the implementation does not sacrifice the original image quality or resolution to achieve the depth-based blurring, which is a limitation of the mode currently. This project explores from ground up a lossless implementation of depth-based blurring using two images of the same scene, one with RGB information and the other with depth information. By using depth image as guidance to the depth information in the RGB image, the resulting image achieves a blurring effect that is also scaled with the distance from the point of focus. 

This project was a final project for graduate-level Digital Image Processing course at Boston University in Spring 2023. 


### How to Use

The code is written in MATLAB and only need to be executed by pressing "RUN" with the RGB and depth images in the same folder. The image capturing using Intel RealSense D435 is written in more detail at Intel's website: https://www.intelrealsense.com/depth-camera-d435/. While this model was used for the code, any 2 images that are RGB (or other color base) and corresponding depth map can also work with the codebase. 

1. Download and install MATLAB (R2022b used for code) and necessary packages for functions used. 
2. Place the code file and 2 images in the same folder
3. Click RUN to run all the lines
4. Image registration window will pop up to register points of similarities the depth and RGB images, which is manually selected by the user. About 6-8 points of similarities was used for high accuracy, depending on how the subject captured. 
5. Change variables as commented to change between foreground and background blurring and also between gradient and non-gradient blurring. 
6. Retreive final image. 

### Examples


