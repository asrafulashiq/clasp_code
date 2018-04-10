function [R_bin, im, events] = bin_detection_tracking_11(im, im_flow, R_bin)

global debug_bin;

im_actual = im;
im_flow_actual = im_flow;

im_flow1 = lensdistort(im_flow_actual, R_bin.k_distort, 'bordertype', 'fit', 'padmethod', 'circular');
%  im = lensdistort(im, R_bin.k_distort, 'bordertype', 'crop', 'padmethod', 'circular'); 
im1 = lensdistort(im_actual, R_bin.k_distort, 'bordertype', 'fit', 'padmethod', 'circular'); 

im_flow1(:,1:20,:) = 0;
im_flow1(:, 140:end,:) = 0;

events = {};

% im = im1;
% im_flow = im_flow1;
mid_point = 487;

im = cat(1, im1(1:mid_point, :, :), im_actual(mid_point+1:end, :, :));
im_flow = cat(1, im_flow1(1:mid_point, :, :), im_flow_actual(mid_point+1:end, :, :));


im_flow_g = rgb2gray(im_flow);
% im_flow_hsv = rgb2hsv(im_flow);

im_filtered = imgaussfilt(im_flow_g, 4);
im_tmp = im_filtered;
im_filtered(im_filtered < R_bin.threshold_img) = 0;

% close operation for the image
se = strel('disk',5);
im_closed = imclose(im_filtered,se);
im_binary = logical(im_closed); %extract people region
im_binary = imfill(im_binary, 'holes');
% 
%  figure(2);imshow(im_binary);
% figure(3); imshow(im_flow);
if debug_bin
    f = figure;
    imshow(im);
    title('set bin')
    r = getrect;
    close(f);
    
    Bin.area = r(3)*r(4);
    Bin.centroid = [r(1)+r(3)/2-1 r(2)+r(4)/2-1]';
    Bin.BoundingBox = r;
    Bin.label = R_bin.label;
    Bin.tracker = [];
    Bin.MajorAxisLength = 0;
    Bin.MinorAxisLength = 0;
    Bin.t_count = 1;
    Bin.frame = 0;
    Bin.belongs_to = R_bin.stack_of_bins{R_bin.label}.belongs_to;
    Bin.state = "full";
    
    R_bin.label = R_bin.label + 1;

    R_bin.bin_array{end+1} = Bin;
    debug_bin = false;
    R_bin.check = R_bin.check+1;
end
    
%% initial bin detection
% remove previous bins region
for i = 1:numel(R_bin.bin_array)
    bb = R_bin.bin_array{i}.BoundingBox;
    r = [max(bb(2),1) min(bb(2)+bb(4)-1,size(im_binary,1)) max(bb(1),1) min(bb(1)+bb(3)-1, size(im_binary,2))];
    im_binary(r(1):r(2), :) = 0;
end

% check bad flow
% im_tmp(im_tmp < 5) = 0;
% im_tmp = logical(im_tmp);
% if sum(im_tmp(:)) > 60000
%     disp('BAD FLOW!!');
%     return;
% end

%% blob analysis
cpro_r1 = regionprops(im_binary,'Area','BoundingBox','MajorAxisLength', ...
    'MinorAxisLength', 'Centroid'); % extract parameters
body_prop = cpro_r1([cpro_r1.Area] > R_bin.limit_min_area & ...
    [cpro_r1.Area] < R_bin.limit_max_area & [cpro_r1.MinorAxisLength] > 80 & ...
    [cpro_r1.MajorAxisLength]./[cpro_r1.MinorAxisLength] > 1.1 & ...
    [cpro_r1.MajorAxisLength]./[cpro_r1.MinorAxisLength] < 1.8);

for i = 1:numel(body_prop)
    
    flag = 1;
    
    if body_prop(i).Centroid(2) > 100 || body_prop(i).Centroid(2) < 52 %||  body_prop(i).Centroid(2) > 150
       continue; 
    end
    
    for j = 1:numel(R_bin.bin_array)
        if norm(R_bin.bin_array{j}.Centroid - body_prop(i).Centroid) < R_bin.limit_distance
            flag = 0;
            break;
        end
    end
    
    if flag==0 || body_prop(i).Centroid(2) > R_bin.limit_init_y
        continue;
    end
    
    % ratio of total area /  number of pixels
    rect_area = body_prop(i).BoundingBox(3)*body_prop(i).BoundingBox(4);
    
    if rect_area / body_prop(i).Area > R_bin.area_ratio
        continue;
    end
    
    % get color
    imcrop_rgb = imcrop(im .* uint8(im_binary), body_prop(i).BoundingBox);
    imcropped = rgb2gray(imcrop_rgb);
%     color = sum(imcropped(:)) / sum(imcropped(:) > 0);
%     if abs(color - 190) > 90
%         fprintf('color value : %d\n', color);
%         continue;
%     end
    
    Bin = body_prop(i);
    Bin.tracker = [];
%     Bin.label = R_bin.label;
    Bin.label =  R_bin.stack_of_bins{R_bin.label}.label;
    Bin.belongs_to = R_bin.stack_of_bins{R_bin.label}.belongs_to;
        
    Bin.t_count = 1;
    Bin.frame = 0;
    Bin.state = "full";
    R_bin.label = R_bin.label + 1;
    
    R_bin.bin_array{end+1} = Bin;
    
    R_bin.check = R_bin.check + 1;
    
    R_bin.event{end+1} = sprintf('Bin %d enters', Bin.label); 
    events{end+1}.text = sprintf('B%d comes out of X-Ray machine', Bin.label);
    
end

%% tracking
bin_array = R_bin.bin_array;

del_exit = [];

for i = 1:numel(bin_array)
    
    bin_array{i}.t_count = bin_array{i}.t_count + 1;
    bin_array{i}.frame = R_bin.current_frame;
    
    if isempty(bin_array{i}.tracker) 
        % init tracker
%         tracker = BACF_tracker(im, bin_array{i}.BoundingBox);
        tracker = R_bin.stack_of_bins{bin_array{i}.label}.tracker;%BACF_tracker(im, bin_array{i}.BoundingBox);
%         new_pos = bin_array{i}.Centroid ;
%         tracker = tracker.setPos(new_pos,[]);
        new_rect = bin_array{i}.BoundingBox;
         tracker = tracker.setRect(new_rect);
        bin_array{i}.t_count = 1;
        
        if R_bin.label == 7
           tracker = BACF_tracker(im, bin_array{i}.BoundingBox); 
        end
        
    else
        tracker = bin_array{i}.tracker;

    end
    
    
    
    [tracker, bb] = tracker.runTrack(im);
    
    new_centre = [bb(1)+bb(3)/2 bb(2)+bb(4)/2]';
    
    if bb(4) > 160
        bin_array{i}.tracker = [];
        continue;
    end
    
    % check if it is close to other bins
    flag_h = 0;
    for j=1:numel(bin_array)
        if j~=i
            if norm(new_centre - bin_array{j}.Centroid) < 70
                flag_h = 1;
                break;
            end
        end
    end
    
    if flag_h==1
         bin_array{i}.tracker = [];
        continue;
    end
    
    bin_array{i}.tracker = tracker;
    bin_array{i}.BoundingBox = bb;
    bin_array{i}.Centroid = new_centre;
    
%     if abs(bin_array{i}.Centroid(1) - size(im,2)/2) > 30
%         bbox = [20 bb(2) size(im,2)-40 bb(4)];
%         centroid = [size(im,2)/2 bin_array{i}.Centroid(2)];
%         bin_array{i}.tracker = BACF_tracker(im, bbox);
%         bin_array{i}.BoundingBox = bbox;
%         bin_array{i}.Centroid = centroid;
%     end

    %% check state
    % set empty or full
    if bin_array{i}.Centroid(2) > mid_point + 80 && ~strcmp(bin_array{i}.state, "empty")
        Iref = im2single(imresize(imread('pair001_frm1.jpg'),0.5));
        rect = double([10 91 152 108]);
        [max_v, ~, ~] = BBS_11(im, bin_array{i}.BoundingBox, Iref, rect);
        if max_v < 0.3
            bin_array{i}.state = "full";
            fprintf('STATE : full : %.2f\n', max_v);
        elseif max_v < 0.6 &&  max_v > 0.25
%             bin_array{i}.state = "empty";
            fprintf('STATE : unspec : %.2f\n', max_v);
        else
            bin_array{i}.state = "empty";
            fprintf('STATE : empty : %.2f\n', max_v);
        end
    end

    %%
    if bin_array{i}.Centroid(2) > R_bin.limit_exit_y 
        R_bin.bin_seq{end+1} = bin_array{i};
        del_exit(end+1) = i;
        R_bin.event{end+1} = sprintf('Bin %d exits scene', bin_array{i}.label);
        
        events{end+1} = sprintf('B%d goest to camera 13', bin_array{i}.label);
    end
    
%     if strcmp(bin_array{i}.state, "empty")
%         R_bin.bin_seq{end+1} = bin_array{i};
%         del_exit(end+1) = i;
%         R_bin.event{end+1} = sprintf('Bin %d is emptied', bin_array{i}.label);
%         
%          events{end+1} = sprintf('P%d collects DVI from B%d', bin_array{i}.belongs_to,...
%              bin_array{i}.label);
%         
%     end
    
end

bin_array(del_exit) = [];
R_bin.check_del = -length(del_exit);

R_bin.bin_array = bin_array;


end