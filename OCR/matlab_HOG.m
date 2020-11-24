function y=matlab_HOG(I)
[features, visualization] = extractHOGFeatures(I,'CellSize',[2 2]);
y=features;
end