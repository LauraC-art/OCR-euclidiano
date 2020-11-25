function y=matlab_HOG(I)
[features, visualization] = extractHOGFeatures(I,'CellSize',[8 8]);
y=features;
end