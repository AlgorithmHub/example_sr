function [im_result im_result_color] = imsuper(imageFilenames, scaleFactor, registration, reconstruction)

  if(~exist('registration','var'))
    registration = 'keren';
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

      % figure; imagesc(tempImage); axis image;
      % pause

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
%      display(i/IMAGESNUMBER);
      im{i} = IMAGES{i};
      im{i} = im2double(im{i}); %double(im{i})/(2^(IMAGESINFO{i}.BitDepth/3));
      imColor{i} = im{i};
      if (size(size(IMAGES{1}), 2) == 3)
          im{i} = rgb2gray(im{i});
      end
      im_part{i} = imColor{i};

  end

  switch registration
    case 'vandewalle'
        [delta_est, phi_est] = estimate_motion(im);
    case 'marcel'
        [delta_est, phi_est] = marcel(im);
    case 'lucchese'
        [delta_est, phi_est] = lucchese(im);
    case 'keren'
        [delta_est, phi_est] = keren(im);
    otherwise
        [delta_est, phi_est] = estimate_motion(im);
  end

  %% signal reconstruction
  im_temp = {};
  im_color1 = {};
  im_color2 = {};

  if (size(size(IMAGES{1}), 2) == 3)
      for i=1:IMAGESNUMBER
          im_temp{i} = rgb2ycbcr(im_part{i});
          im_part{i} = im_temp{i}(:,:,1);

          % temp = circshift(im_part{i}, -[round(scaleFactor * delta_est(i,1)), round(scaleFactor * delta_est(i,2))]);
          % temp = imrotate(temp, phi_est(i), 'nearest', 'crop');
          % figure; imagesc(temp); axis image;
          % pause;
      end
      cb_temp = im_temp{1}(:,:,2);
      cr_temp = im_temp{1}(:,:,3);
      im_color1 = imresize(cb_temp, scaleFactor, 'bicubic');
      im_color2 = imresize(cr_temp, scaleFactor, 'bicubic');
  end


  % for i=1:IMAGESNUMBER
  %     temp = circshift(im_part{i}, [round(delta_est(i,1)), round(delta_est(i,2))]);
  %     temp = imrotate(temp, phi_est(i), 'nearest', 'crop');
  %     figure; imagesc(temp); axis image;
  %     pause;
  % end


  switch reconstruction
      case 'interpolation'
          im_result = interpolation(im_part,delta_est,phi_est,scaleFactor);
      case 'papoulis-gerchberg'
          im_result = papoulisgerchberg(im_part,delta_est,scaleFactor);
      case 'iteratedBP'
          im_result = iteratedbackprojection(im_part, delta_est, phi_est, scaleFactor);
      case 'robustSR'
          im_result = robustSR(im_part, delta_est, phi_est, scaleFactor);
      case 'pocs' % no phi_est
          im_result = pocs(im_part,delta_est,scaleFactor);
      case 'normConv'
          correctNoise = false;
          twoPass = false;
          im_result = n_conv(im_part,delta_est,phi_est,scaleFactor,correctNoise,twoPass);%Last two parameters are booleans for: noiseCorrect and TwoPass
      otherwise
          im_result = interpolation(im_part,delta_est,phi_est,scaleFactor);
  end

  %% if RGB, layer colored images
  if (size(size(IMAGES{1}), 2) == 3)
      temp_result_ycbcr(:,:,1) = im_result;
      temp_result_ycbcr(:,:,2) = im_color1;
      temp_result_ycbcr(:,:,3) = im_color2;
      im_result_color = ycbcr2rgb(temp_result_ycbcr);
  else
      im_result_color = 0;
  end
