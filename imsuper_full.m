function [im_result im_color] = imsuper_full(imageFilenames, scaleFactor, registration, reconstruction)

  if(~exist('registration','var'))
    registration = 'vandewalle';
  end

  if(~exist('reconstruction','var'))
    reconstruction = 'interpolation';
  end

  %% load images
  IMAGESNUMBER = length(imageFilenames);
  IMAGES = {};
  IMAGESINFO = {};

  IMAGES{1} = imread(imageFilenames{1});
  IMAGESINFO{1} = imfinfo(imageFilenames{1});

  for i=2:IMAGESNUMBER
      tempImage = imread(imageFilenames{i});
      tempInfo = imfinfo(imageFilenames{i});

      % check for size mismatch
      if not(size(IMAGES{1}) == size(tempImage))
          error(['Image ' IMAGESSTRING{i} ' has not the same size as image ' IMAGESSTRING{1}], 'Size error');
          return;
      elseif not(IMAGESINFO{1}.BitDepth == tempInfo.BitDepth)
          error(['Image ' IMAGESSTRING{i} ' is not the same type as image ' IMAGESSTRING{1}], 'Size error');
          return;
      else
          IMAGES{i} = tempImage;
          IMAGESINFO{i} = tempInfo;
      end
  end

  %%% preprocessing images
  for i=1:IMAGESNUMBER
      im{i} = IMAGES{i};
      im{i} = im2double(im{i}); %double(im{i})/(2^(IMAGESINFO{i}.BitDepth/3));
      imColor{i} = im{i};
      if (size(size(IMAGES{1}), 2) == 3)
          im{i} = rgb2gray(im{i});
      end
  end

  %% registration
  switch registration
    case 'vandewalle'
        [delta_est, phi_est] = estimate_motion(im,0.6,25);
    case 'marcel'
        [delta_est, phi_est] = marcel(im,2);
    case 'lucchese'
        [delta_est, phi_est] = lucchese(im,2);
    case 'keren'
        [delta_est, phi_est] = keren(im);
    otherwise
        [delta_est, phi_est] = estimate_motion(im,0.6,25);
  end

  %% signal reconstruction
  if (size(size(IMAGES{1}), 2) == 3)

      for i=1:IMAGESNUMBER
          im_R{i} = imColor{i}(:,:,1);
          im_G{i} = imColor{i}(:,:,2);
          im_B{i} = imColor{i}(:,:,3);
      end

      switch reconstruction
          case 'interpolation'
              im_result = interpolation(im_R,delta_est,phi_est,scaleFactor);
              im_result(:,:,2) = interpolation(im_G,delta_est,phi_est,scaleFactor);
              im_result(:,:,3) = interpolation(im_B,delta_est,phi_est,scaleFactor);
          case 'papoulis-gerchberg'
              im_result = papoulisgerchberg(im_R,delta_est,scaleFactor);
              im_result(:,:,2) = papoulisgerchberg(im_G,delta_est,scaleFactor);
              im_result(:,:,3) = papoulisgerchberg(im_B,delta_est,scaleFactor);
          case 'iteratedBP'
              im_result = iteratedbackprojection(im_R, delta_est, phi_est, scaleFactor);
              im_result(:,:,2) = iteratedbackprojection(im_G, delta_est, phi_est, scaleFactor);
              im_result(:,:,3) = iteratedbackprojection(im_B, delta_est, phi_est, scaleFactor);
          case 'robustSR'
              im_result = robustSR(im_R, delta_est, phi_est, scaleFactor);
              im_result(:,:,2) = robustSR(im_G, delta_est, phi_est, scaleFactor);
              im_result(:,:,3) = robustSR(im_B, delta_est, phi_est, scaleFactor);
          case 'pocs'
              im_result = pocs(im_R,delta_est,scaleFactor);
              im_result(:,:,2) = pocs(im_G,delta_est,scaleFactor);
              im_result(:,:,3) = pocs(im_B,delta_est,scaleFactor);
          case 'normConv'
              correctNoise = false;
              twoPass = false;
              im_result = n_conv(im_R,delta_est,phi_est,scaleFactor,correctNoise,twoPass);%Last two parameters are booleans for: noiseCorrect and TwoPass
              im_result(:,:,2) = n_conv(im_G,delta_est,phi_est,scaleFactor,correctNoise,twoPass);%Last two parameters are booleans for: noiseCorrect and TwoPass
              im_result(:,:,3) = n_conv(im_B,delta_est,phi_est,scaleFactor,correctNoise,twoPass);%Last two parameters are booleans for: noiseCorrect and TwoPass
          otherwise
              im_result = interpolation(im_R,delta_est,phi_est,scaleFactor);
              im_result(:,:,2) = interpolation(im_G,delta_est,phi_est,scaleFactor);
              im_result(:,:,3) = interpolation(im_B,delta_est,phi_est,scaleFactor);
      end

  else

      switch reconstruction
          case 'interpolation'
              im_result = interpolation(im,delta_est,phi_est,scaleFactor);
          case 'papoulis-gerchberg'
              im_result = papoulisgerchberg(im,delta_est,scaleFactor);
          case 'iteratedBP'
              im_result = iteratedbackprojection(im, delta_est, phi_est, scaleFactor);
          case 'robustSR'
              im_result = robustSR(im, delta_est, phi_est, scaleFactor);
          case 'pocs'
              im_result = pocs(im,delta_est,scaleFactor);
          case 'normConv'
              correctNoise = false;
              twoPass = false;
              im_result = n_conv(im,delta_est,phi_est,scaleFactor,correctNoise,twoPass);%Last two parameters are booleans for: noiseCorrect and TwoPass
          otherwise
              im_result = interpolation(im,delta_est,phi_est,scaleFactor);
      end

  end

im_color = im_result;
