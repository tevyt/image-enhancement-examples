% Problem 1 %
% Plot original Image %
imageName = 'zebra.jpg';
sampleImage = toIntensityImage(imread(imageName));
figure, subplot(1, 2, 1), imshow(sampleImage);
subplot (1, 2, 2), histogram(sampleImage);
sgtitle('Original Image.');
gammaHigh = 1.2;
gammaLow = 0.8;
lightContrast = enhanceContrast(sampleImage, gammaHigh);
darkContrast = enhanceContrast(sampleImage, gammaLow);

% Increasing contrast
figure, subplot(2, 2, 1), imshow(lightContrast);
title(sprintf('γ = %.2f', gammaHigh));
subplot(2, 2, 2), imshow(darkContrast);
title(sprintf('γ = %.2f', gammaLow));
subplot(2, 2, 3), histogram(lightContrast);
subplot(2, 2, 4), histogram(darkContrast);
sgtitle('Contrast.')

% Thresholding
threshold = 115;
thresholdImage = applyThreshold(sampleImage, threshold);
figure, subplot(1, 2, 1), imshow(thresholdImage);
subplot(1, 2, 2), histogram(thresholdImage);
sgtitle(sprintf('Threshold. t = %d', threshold));

%Equalizing
cumulativeHistogram = createCumulativeHistogram(sampleImage);
equalizedImage = equalizeImage(sampleImage, cumulativeHistogram);
figure, subplot(1, 2, 1), imshow(equalizedImage);
subplot(1, 2, 2),histogram(equalizedImage);
sgtitle('Equalized Image.');


%Problem 2
% 1x2 convolution
horizontal1x2 = convolve1x2Horizontal(sampleImage);
vertical1x2 = convolve1x2Vertical(sampleImage);
combined1x2 = horizontal1x2 + vertical1x2;
figure, subplot(2, 3, 1), imshow(horizontal1x2);
title('Horizontal');
subplot(2, 3, 2), imshow(vertical1x2);
title('Vertical');
subplot(2, 3, 3), imshow(combined1x2);
title('Combined');
subplot(2, 3, 4), histogram(horizontal1x2);
subplot(2, 3, 5), histogram(vertical1x2);
subplot(2, 3, 6), histogram(combined1x2);
sgtitle('1x2 Convolution.')

sobelHorizontalImage = sobelHorizontal(sampleImage);
sobelVerticalImage = sobelVertical(sampleImage);
combinedSobelImage = sobelVerticalImage + sobelHorizontalImage;
figure, subplot(2, 3, 1), imshow(sobelHorizontalImage);
title('Horizontal');
subplot(2, 3, 2), imshow(sobelVerticalImage);
title('Vertical');
subplot(2, 3, 3), imshow(combinedSobelImage);
title('Combined');
subplot(2, 3, 4), histogram(sobelHorizontalImage);
subplot(2, 3, 5), histogram(sobelVerticalImage);
subplot(2, 3, 6), histogram(combinedSobelImage);
sgtitle('Sobel operator.')

sobel1x2Difference = combinedSobelImage - combined1x2;
figure, subplot(1, 1, 1), imshow(sobel1x2Difference);
title('Difference between sobel image and 1x2 image.');

artificialImage = toIntensityImage(imread('art-zebra.jpeg'));

artificialSobel = sobelVertical(artificialImage) + sobelHorizontal(artificialImage);
figure, subplot(1, 2, 1), imshow(artificialSobel);
subplot(1, 2, 2), imshow(combinedSobelImage);
sgtitle("Photograph vs. Man-made image.")

sobelEdgeMap = gradientImageToEdgeMap(combinedSobelImage, 0.02);
edgeMap1x2 = gradientImageToEdgeMap(combined1x2, 0.02);
figure, subplot(1, 2, 1), imshow(sobelEdgeMap);
title('Sobel Operator.');
subplot(1, 2, 2), imshow(edgeMap1x2);
title('1x2 Convolution.')
sgtitle('Edge Maps.')

edgeDetector5x5Horizontal = [
        0, -1, 0, 1, 0;
        -1, -2,0, 2, 1;
        -2, -4,0, 4, 2;
        -1, -2, 0, 2, 1;
        0, -1, 0, 1, 0;
    ];

edgeDetector7x7Horizontal = [
    0,0,-1,0,1,0,0;
    0,-1,-2,0,2,1,0;
    -1,-2,-4,0,4,2,1;
    -2,-4,-8,0,8,4,2;
    -1,-2,-4,0,4,2,1;
    0,-1,-2,0,2,1,0;
    0,0,-1,0,1,0,0;
];

horizontal5x5 = convolve(sampleImage, edgeDetector5x5Horizontal);
horizontal7x7 = convolve(sampleImage, edgeDetector7x7Horizontal);




function intensityImage = toIntensityImage(sampleImage)
    intensityImage = (0.299 * sampleImage(:, :, 1)) + (0.587 * sampleImage(:, :, 2)) + (0.114 * sampleImage(:, :, 3));
end

function enhancedImage = enhanceContrast(sampleImage, gamma)
    enhancedImage = double(sampleImage)/255;
    enhancedImage = min(power(enhancedImage, gamma), 1.0);
    enhancedImage = uint8(enhancedImage * 255);
end

function enhancedImage = applyThreshold(sampleImage, t)
    enhancedImage = sampleImage;
    enhancedImage(sampleImage > t) = 255;
    enhancedImage(sampleImage <= t) = 0;
end

function cumulativeHistogram = createCumulativeHistogram(sampleImage)
    cumulativeHistogram = zeros(256);
    for i=1:256
       cumulativeHistogram(i) = length(sampleImage(sampleImage == i - 1)); 
       if(i ~= 1)
           cumulativeHistogram(i) = cumulativeHistogram(i) + cumulativeHistogram(i - 1);
       end
    end
end

function equalizedImage = equalizeImage(sampleImage, cummulativeHistogram)
    equalizedImage = sampleImage;
    pixels = zeros(256);
    for i=1:256
        pixels(i) = length(sampleImage(sampleImage == i));
    end

    for x=1:length(sampleImage(:, 1))
        for y=1:length(sampleImage)
            originalGrayLevel = sampleImage(x, y);    
            numberOfPixels = pixels(originalGrayLevel + 1);
            equalizedImage(x, y) = max(0, uint8(cummulativeHistogram(originalGrayLevel + 1)/numberOfPixels) - 1);
        end
    end
end

function convolvedImage = convolve1x2Horizontal(sampleImage)
    convolvedImage = sampleImage;
    for x=1:length(sampleImage(:, 1))
        for y=1:length(sampleImage)
            if(x > 1)
                convolvedImage(x, y) = abs(sampleImage(x, y) - sampleImage(x - 1, y));
            end
        end
    end
end

function convolvedImage = convolve1x2Vertical(sampleImage)
    convolvedImage = sampleImage;
    for x=1:length(sampleImage(:, 1))
        for y=1:length(sampleImage)
            if(y > 1)
                convolvedImage(x, y) = abs(sampleImage(x, y) - sampleImage(x, y - 1));
            end
        end
    end
end

function convolvedImage = sobelHorizontal(sampleImage)
    convolvedImage = sampleImage;
    for x=1:length(sampleImage(:, 1))
        for y=1:length(sampleImage(1, :))
            if(y > 1 && x > 1 && y < length(sampleImage) && x < length(sampleImage(:, 1)))
                newValue = sampleImage(x + 1, y - 1) - sampleImage(x - 1, y - 1);
                newValue = newValue + 2 * ( sampleImage(x + 1, y) - sampleImage(x - 1, y));
                newValue = newValue + sampleImage(x + 1, y + 1) - sampleImage(x - 1, y -1);
                convolvedImage(x, y) = abs(newValue);
            end
        end
    end
end

function convolvedImage = sobelVertical(sampleImage)
    convolvedImage = sampleImage;
    for x=1:length(sampleImage(:, 1))
        for y=1:length(sampleImage(1, :))
            if(y > 1 && x > 1 && y < length(sampleImage) && x < length(sampleImage(:, 1)))
                newValue = sampleImage(x + 1, y - 1) - sampleImage(x - 1, y - 1);
                newValue = newValue + 2 * ( sampleImage(x, y + 1) - sampleImage(x, y + 1));
                newValue = newValue + sampleImage(x + 1, y + 1) - sampleImage(x - 1, y -1);
                convolvedImage(x, y) = abs(newValue);
            end
        end
    end
end

function edgeMap = gradientImageToEdgeMap(sampleImage, t)
    pixels = sampleImage(:);
    pixels = sort(pixels);
    %if t = 1, take 100% of pixels. If t = 0.5, take top 50%
    %of pixels etc.
    numberOfPixelsToTake = round(t * length(pixels));
    lowestValue = pixels(length(pixels) - numberOfPixelsToTake);
    edgeMap = sampleImage;
    edgeMap(sampleImage >= lowestValue) = 255;
    edgeMap(sampleImage < lowestValue) = 0;
end

function convolvedImage = convolve(sampleImage, kernel)
    buffer = (length(kernel(:, 1)) - 1)/2;
    convolvedImage = sampleImage;
    for x=1:length(sampleImage(:, 1))
        for y=1:length(sampleImage(1, :))
            if(x > buffer && y > buffer && x + buffer < length(sampleImage(:, 1)) && y + buffer < length(sampleImage(1, :)))
                newValue = int16(0);
                areaUnderKernel = sampleImage(x - buffer:x+buffer, y - buffer:y + buffer);
                for i=1:length(kernel(:, 1))
                    for j=1:length(kernel(1, :))
                        nextComponent = int16(areaUnderKernel(i, j)) * int16(kernel(i, j));
                        newValue = newValue + nextComponent;
                    end
                end
                convolvedImage(x, y) = abs(newValue);
            end
        end
    end
end



