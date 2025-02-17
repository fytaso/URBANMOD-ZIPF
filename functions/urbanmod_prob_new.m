function urbanmod_prob_new(region, scenario, ntimes)
%URBANMOD 
%   Simulates urban expansion
%   INPUT:
%       region     -- Ending year of the simulation
%       scenario   -- The scenario of the simulation
%       nurban     -- Total number of urban pixels at the end of simulation
%       nntimes    -- Number of runs in Monte Carlo simulation
%   OUTPUT: every 10 years
%       Ensemble    -- results/{region}/{scenario}/{yr1}/*.tif
%       Probability -- results/{region}/{scenario}_{yr1}.tif 

    %% Testing
%     region   = 'CHN';
%     region   = 'USA';
%     region   = 'BGD';
%     region   = 'NZL';
%     region   = 'SLB';
%     scenario = 'SSP5';
%     ntimes   = 4;
%     

    %% Read data
    path = fullfile('results', region);
    % Suitability for urban expansion
    [suit, header] = readgeoraster(fullfile(path, 'suitability.tif'), 'CoordinateSystemType', 'planar');
    % Set negative suitability to NAN
    suit(suit < 0) = nan;
    % Rescale suitability to [0-1]
    suit = suit / max(suit(:));
    warning('off','all');
    info = georasterinfo(fullfile(path, 'suitability.tif'));
    
    %% Main loop
    disp(['Running ', region, ' ', scenario]);
    % Parallel loop through n times of simulations
    parfor tt = 1:ntimes
        % Set starting year in 2015
        year_start  = 2015;
        % Read urban land areas
        ul_areas = readtable("results/urban_land.csv");
        ul_area_sub = ul_areas(...
            strcmp(ul_areas.REGION, region) & ...
            strcmp(ul_areas.SCENARIO,scenario),:);
        % Loop through years
        for i = 1:length(ul_area_sub.year)
            % Read year and urban land area
            year_end = ul_area_sub.year(i);
            nyr = year_end - year_start;
            % Output filepath for ensemble
            path_out = fullfile('results', region, scenario, num2str(year_end));
            % If the filepath doesn't exist, create it
            if ~isfolder(path_out)
                mkdir(path_out);
            end
            % Output filename
            file_out = fullfile(path_out, strcat(num2str(tt,'%04d'),'.tif'));
            % If output file exists, skip this round
            if isfile(file_out)
                % Update starting year
                year_start = year_end;
                % Skip this round
                continue;
            end
            % Initial urban land cover
            [urban_start, ~] = readgeoraster(fullfile(path, 'urban_2015.tif'));
            % If not starting in 2015, urban_start from last decade
            if year_start ~= 2015
                path_in = fullfile('results', region, scenario, num2str(year_start));
                file_in = fullfile(path_in, strcat(num2str(tt,'%04d'),'.tif'));
                [urban_start,~] = readgeoraster(file_in);
            end
            urban_start(urban_start < 0) = 0;
            % Load number of urban pixels
            nurban = ul_area_sub(ul_area_sub.year==year_end,:).urban_land;
            % Run simulation once 
            urban_end = urbanmod_new(urban_start, suit, nyr, nurban, year_start, tt);
            % Output one simulation
            geotiffwrite(file_out,urban_end,header,'CoordRefSysCode', 'EPSG:6933');
            % Update starting year
            year_start = year_end;
        end
    end

    %% Calculate ensemble mean
    % Read urban land areas
    ul_areas = readtable("results/urban_land.csv");
    ul_area_sub = ul_areas(...
        strcmp(ul_areas.REGION, region) & ...
        strcmp(ul_areas.SCENARIO,scenario),:);
    % Output filepath for ensemble
    for i = 1:length(ul_area_sub.year)
        year_end = ul_area_sub.year(i);
        path_out = fullfile('results', region, scenario, num2str(year_end));
        fprintf('Calculating ensemble mean, %s, %s, %d...\n', region, scenario, year_end);
        [nrow, ncol] = size(suit);
        urban_sum = zeros(nrow, ncol);
        for tt = 1:ntimes
            file_out  = fullfile(path_out, strcat(num2str(tt,'%04d'),'.tif'));
            urban_tt  = readgeoraster(file_out);
            urban_sum = urban_sum + urban_tt;
        end
        % Output ensemble mean
        urban_mean = urban_sum / ntimes;
        file_en_out = fullfile('results', region, ...
            strcat(scenario, '_', num2str(year_end), '.tif'));
        geotiffwrite(file_en_out, urban_mean, header, "CoordRefSysCode", 'EPSG:6933');
    end
end