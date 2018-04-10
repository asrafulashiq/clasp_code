if R_9.current_frame <= R_9.end_frame
    
    img = imread(fullfile(R_9.filename, sprintf('%04i.jpg', R_9.current_frame)));
    im_c = imresize(img,scale);%original image
    im_c = imrotate(im_c, R_9.rot_angle);
    
    if R_9.current_frame >= 1934
        1;
    end
    R_9.R_bin.event = {};
    R_9.R_people.event = {};
    
    % flow image
    try
        im_flow_all = imread(fullfile(R_9.flow_dir, sprintf('%04d_flow.jpg', R_9.current_frame)));
        im_flow_all = imrotate(im_flow_all, R_9.rot_angle);
    catch
        warning('Error reading file : %s',...
            fullfile(R_9.flow_dir, sprintf('%04d_flow.jpg', R_9.current_frame)));
        im_flow_all = [];
    end
    
    if R_9.current_frame  >= 1984
        1;
    end
    
    %% bin tracking
    im_b = im_c(R_9.R_bin.reg(3):R_9.R_bin.reg(4),R_9.R_bin.reg(1):R_9.R_bin.reg(2),:); % people region
    
    if ~isempty(im_flow_all)
        im_flow_bin = im_flow_all(R_9.R_bin.reg(3):R_9.R_bin.reg(4),R_9.R_bin.reg(1):R_9.R_bin.reg(2),:);
    else
        im_flow_bin = [];
    end
    
    % R_9.R_bin = bin_detection_tracking(im_b, im_flow_bin, R_9.R_bin);
    [R_9.R_bin, event_bin] = bin_detect_prev(im_b, im_flow_bin, R_9.R_bin, R_9.R_people);
    
    %% people tracking
    im_r = im_c(R_9.R_people.reg(3):R_9.R_people.reg(4),R_9.R_people.reg(1):R_9.R_people.reg(2),:); % people region
    
        if ~isempty(im_flow_all)
            im_flow_people = im_flow_all(R_9.R_people.reg(3):R_9.R_people.reg(4),R_9.R_people.reg(1):R_9.R_people.reg(2),:);
            [R_9.R_people, R_2.R_people, event_people] = people_detector_tracking(im_r, im_flow_people, R_9.R_people, R_2.R_people);
        else
            im_flow_people = [];
        end
    R_9.R_people.im = im_r;
    
    % detect people
    
    
    %% display image
    %display_image_bin(im_b, R_9);
    %im = display_image_people(im_r, R_9);
    
    im = display_image(im_c, R_9);
    
%     [im_text, R_9.recent_events] = display_event(R_9, size(im, 1));
    
%     im = cat(2, im, im_text);
    
    figure(9);
    imshow(im);
    
    %% concat event
    events = {};
    for icounter = 1:numel(event_bin)
        events{end+1} = event_bin{icounter};
    end
    for icounter = 1:numel(event_people)
        events{end+1} = event_people{icounter};
    end
    R_9.event_struct{R_9.current_frame} = events;
    
    
    fprintf('frame : %04i\n', R_9.current_frame);
    
    %warning('off','last');
    
    % R_9.write
    if R_9.write
        writeVideo(R_9.writer, im);
    end
    
    if R_9.is_save_frame 
       fileofthis = fullfile(R_9.frame_save_folder, sprintf('%04d.jpg', R_9.current_frame));
       imwrite(im, fileofthis); 
    end
    
    R_9.current_frame = R_9.current_frame + 1;
end