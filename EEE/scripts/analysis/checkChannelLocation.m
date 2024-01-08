function locations = checkChannelLocation(data, channels)
% data structure must have an elec substructure


e = data.elec;
chanloc = cell(numel(channels), 1);

    for c = 1:3%numel(channels)
        try 
            idx = strcmp(channels{c}, e.label); %find row that matches channel name
            chanloc{c} = e.posname{idx};
        catch
            sprintf('Channel %s does not exist in the provided data.', channel(c))
        end %try 


    end %for channels

locations = chanloc;

end %function

