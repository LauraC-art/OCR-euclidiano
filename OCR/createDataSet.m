function createDataSet()
    load templates
    global templates

    global tempHog
    %Templates son matrices binarias en celdas
    c=0;
    %createDataSet
    for i=1:size(templates,2)
        %imshow(templates{i})
        %tempHog{i}=matlab_HOG(templates{i});
        tempHog{i}=hog_propio(templates{i});
        c=tempHog;
        %disp(size(c))
    end
end