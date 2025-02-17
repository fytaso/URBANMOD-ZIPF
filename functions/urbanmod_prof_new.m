function urbanmod_prof_new(path, year_start, year_end, scenario, nurban, nntimes)
%URBANMOD 
%   Simulates urban expansion
%   INPUT:
%       path   -- Path to the region folder
%       year_start -- Starting year of the simulation
%       year_end   -- Ending year of the simulation
%       scenario   -- The scenario of the simulation
%       nurban     -- Total number of urban pixels at the end of simulation
%       nntimes     -- Number of runs in Monte Carlo simulation
%   OUTPUT:
%       Ensemble    -- path/{scenario}/{yr1}/*.tif
%       Probability -- path/{scenario}_{yr1}.tif

    %% Testing
    path       = fullfile(pwd, 'results', 'CHN');
    year_start = 2015;
    year_end   = 2050;
    scenario   = 'SSP5';
    nurban     = 428120;
    ntimes     = 7;
    % Test parallel computing
    parpool('local', ntimes);

    %% Model parameter
    winsize = 3;

    %% Read data
	filename_urban = fullfile(path, ...
        strcat('urban', '_', num2str(year_start), '.tif'));
    [urban, header] = readgeoraster(filename_urban);
    info = geotiffinfo(filename_urban);
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTModelTypeGeoKey     = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTRasterTypeGeoKey    = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.ProjectedCSTypeGeoKey = 32767;
    urban = double(urban);
    urban(urban < 0) = 0;
    [suit, ~] = readgeoraster(fullfile(path, 'suitability.tif'));
    suit(suit < 0) = nan;
    % number of years
    nyr = year_end - year_start;
    % number of new urban pixels per year
    nnew = ceil((nurban - sum(urban(:))) / nyr);

    %% Create output folder
    path_out = fullfile(path, strcat(scenario, '_', num2str(year_end)));
    mkdir(path_out);

    %% Create grid
    [nrow, ncol] = size(urban);
    [cols, rows] = meshgrid(1:ncol, 1:nrow);

    %% Suitability distribution of urbanized pixels
    nbins = 20;
    [prob, ctrs] = suitability_distribution(urban, suit, nbins);
    
    %% Main loop
    sizes = cell(ntimes, 1);
    urban_prob = zeros(nrow, ncol, ntimes);    
%     for tt = 1:ntimes
    parfor tt = 1:ntimes    
        disp(strcat(num2str(tt, '%d'), 'th time;'));
        urban_new = urban;
        for t = 1:nyr    
            % debug print
            fprintf(1, 'Running %4d, ', year_start + t); if(mod(t,5)==0), fprintf(1, '\n'); end
            % pixels remain to urbanized
            nremain = nnew;

            %% keep urbanizing pixels until number is met
            while nremain > 0                

                % gather neighbor pixels as candidates
    %             neighbor     = logical(neighbor_pixels(urban_new, winsize));
                neighbor     = logical(neighbor_pixels_gibrats(urban_new, winsize));
                neighbor_row = rows(neighbor);
                neighbor_col = cols(neighbor);

                % gather suitability of candidates
                suit_can = suit(neighbor);

                % indices of selected pixels
                idx_sel  = randomSelectByDistribution(suit_can, prob, ctrs, nremain);

                % locations of selected pixels
                idx_rows_sel = neighbor_row(idx_sel);
                idx_cols_sel = neighbor_col(idx_sel);

                % turn selected pixels into urban
                for ii = 1:length(idx_sel)
                    urban_new(idx_rows_sel(ii), idx_cols_sel(ii)) = 1;
                end

                % reduce number of remaining pixels
                nremain = nremain - length(idx_sel);
            end                        
        end
        geotiffwrite(fullfile(path_out, strcat(num2str(tt, '%04d'), '.tif')), ...
            logical(urban_new), header, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
        urban_prob(:,:,tt) = urban_new;
        sizes{tt} = urban_size(urban_new, winsize);
    end
    
    % calculate probability   
    urban_new = mean(urban_prob, 3);
        
    %% Output result
    urban_size_file = strcat(in_path, 'size-',  control(1:4), '.mat');
    save(urban_size_file, 'sizes',      '-v7.3');
    geotiffwrite(strcat(path_out, '.tif'), urban_new, header, ...
        'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
end