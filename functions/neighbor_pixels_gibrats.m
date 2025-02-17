function urban_sel = neighbor_pixels_gibrats( urban, winsize )
%NEIGHBOR_PIXELS Obtain neighbor pixels of existing urban lands, according
%to Gibrat's Law: neighbor pixels of larger conncected components have
%higher probability to be selected.
%   INPUT
%       urban     -- matrix of urban pixels
%       winsize   -- size of the smooth window
%   OUTPUT
%       neighbors -- matrix of neighbors of input urban pixels, excluding
%                    the existing urban pixels     
    
%     kernel = ones(winsize, winsize);  
    kernel = [0 1 0; 1 1 1; 0 1 0];

    % connceted component
    cc = bwconncomp(urban, kernel);
    npxls = cellfun(@numel, cc.PixelIdxList);
    
    % mark each pixel according to component sizes
    urban_size = single(urban);
    for ii = 1:cc.NumObjects
        urban_size(cc.PixelIdxList{ii}) = npxls(ii);
    end
    
    %% mark neighboring pixels according to sizes
%     neighbors = ordfilt2(urban_size, 9, kernel);
    neighbors = ordfilt2(urban_size, 5, kernel);
    neighbors(urban == 1) = 0;
    
    %% randomly select pixels, biggers cities' neighbors are more likely
    max_size = max(npxls); % size of the largest city
    hst_size = hist(npxls, max_size); % distribution of city sizes
    lst_size = 1:max_size; % sizes of city
    hst_nghb = hist(neighbors(neighbors > 0), max_size); % distribution of neighbor sizes
    max_nghb = hst_nghb(end);
    prob_sel = max_nghb / max_size .* lst_size .* hst_size ./ hst_nghb;
    prob_sel(hst_nghb == 0) = 0;
    
    urban_prob = zeros(size(urban));
    for ii = 1:length(prob_sel)
        if prob_sel(ii) > 0
            urban_prob(urban_size == ii) = prob_sel(ii);
        end
    end
    urban_prob = imboxfilt(urban_prob, winsize);
    urban_prob(urban == 1) = 0;
    urban_prob = urban_prob ./ max(urban_prob(:));
    urban_rand = rand(size(urban));
    urban_sel  = zeros(size(urban));
    urban_sel(urban_rand <= urban_prob) = 1;
    
    %% Case with only one urban cluster
    % When there is only one urban cluster the size-based selection fails
    % In this case, all neighboring pixels of the cluster are chosen
    if (sum(urban_sel(:))==0)
        urban_sel(neighbors>0) = 1;
    end

    %% convolution fileter
%     neighbors = conv2(urban, kernel);    
%     [nrow, ncol] = size(urban);
%     neighbors = neighbors(2:nrow+1, 2:ncol+1);     
%     neighbors(urban == 1)    = 0;
%     neighbors(neighbors > 1) = 1;
    

end

