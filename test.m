pkg load image;
pkg load signal;

setNumbers = [1:9];

sampleFiles = {'./sample1/', './sample2/', './sample3/', './sample4/', './sample5/', './sample6/', './sample7/', './sample8/', './sample9/'};
scaleFactor = [ 4 12  8  8  8  4  4  4  4];
runFull     = [ 0  0  0  0  0  0  0  0  1];
maxImages   = [ 4 40 30 40 20 16 15  4 10];

for n = setNumbers

  files = dir([sampleFiles{n} '*.png']);
  imageFilenames = {files(1:maxImages(n)).name};
  imageFilenames = cellfun(@(x) [sampleFiles{n} x], imageFilenames, 'UniformOutput', false)

  tic
  if(runFull(n))
    [im_result im_result_color] = imsuper_full(imageFilenames, scaleFactor(n));
  else
    [im_result im_result_color] = imsuper(imageFilenames, scaleFactor(n));
  end
  toc

  if(im_result_color ~= 0)
    im_result = im_result_color;
  end

  figure; imagesc(flipud(im_result)); axis image;
  imwrite(im_result, ['im_result_' num2str(n) '.png']);

end
