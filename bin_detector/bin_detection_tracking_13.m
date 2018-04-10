function [R_bin, events] = bin_detection_tracking_13(im, im_flow, R_bin)


% im_flow = lensdistort(im_flow, R_bin.k_distort);

% im_flow_g = rgb2gray(im_flow);
% im_flow_hsv = rgb2hsv(im_flow);
% 
% im_filtered = imgaussfilt(im_flow_g, 4);
% im_tmp = im_filtered;
% im_filtered(im_filtered < R_bin.threshold_img) = 0;
% 
% % close operation for the image
% se = strel('disk',5);
% im_closed = imclose(im_filtered,se);
% im_binary = logical(im_closed); %extract people region
% im_binary = imfill(im_binary, 'holes');
% im_binary_orig = im_binary;

% figure(2);imshow(im_binary);
% figure(3); imshow(im_flow);

%% initial bin detection
% remove previous bins region
% for i = 1:numel(R_bin.bin_array)
%     bb = R_bin.bin_array{i}.BoundingBox;
%     r = [max(bb(2),1) min(bb(2)+bb(4)-1,size(im_binary,1)) max(bb(1),1) min(bb(1)+bb(3)-1, size(im_binary,2))];
%     im_binary(r(1):r(2), r(3):r(4)) = 0;
% end
% 
% % check bad flow
% im_tmp(im_tmp < 5) = 0;
% im_tmp = logical(im_tmp);
% if sum(im_tmp(:)) > 60000
%     disp('BAD FLOW!!');
%     return;
% end
% 
% %% blob analysis
% cpro_r1 = regionprops(im_binary,'Area','BoundingBox','MajorAxisLength', ...
%     'MinorAxisLength', 'Centroid'); % extract parameters
% body_prop = cpro_r1([cpro_r1.Area] > R_bin.limit_min_area & ...
%     [cpro_r1.Area] < R_bin.limit_max_area & [cpro_r1.MinorAxisLength] > 120 & ...
%     [cpro_r1.MajorAxisLength]./[cpro_r1.MinorAxisLength] > 1.1 & ...
%     [cpro_r1.MajorAxisLength]./[cpro_r1.MinorAxisLength] < 1.8);
% 
% for i = 1:numel(body_prop)
%     
%     flag = 1;
%     
%     for j = 1:numel(R_bin.bin_array)
%         if norm(R_bin.bin_array{j}.Centroid - body_prop(i).Centroid) < R_bin.limit_distance
%             flag = 0;
%             break;
%         end
%     end
%     
%     if flag==0 || body_prop(i).Centroid(2) > R_bin.limit_init_y
%         continue;
%     end
%     
%     % ratio of total area /  number of pixels
%     rect_area = body_prop(i).BoundingBox(3)*body_prop(i).BoundingBox(4);
%     
%     if rect_area / body_prop(i).Area > R_bin.area_ratio
%         continue;
%     end
%     
%     % get color
% %     imcrop_rgb = imcrop(im .* uint8(im_binary), body_prop(i).BoundingBox);
% %     imcropped = rgb2gray(imcrop_rgb);
% %     color = sum(imcropped(:)) / sum(imcropped(:) > 0);
% %     if abs(color - 190) > 90
% %         fprintf('color value : %d\n', color);
% %         continue;
% %     end
%     
%     Bin = body_prop(i);
%     Bin.tracker = [];
%     Bin.label = R_bin.label;
%     R_bin.label = R_bin.label + 1;
%     
%     R_bin.bin_array{end+1} = Bin;
%     
% end

global debug_bin;

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
    Bin.belongs_to = 1;
    Bin.state = "full";
    
    R_bin.label = R_bin.label + 1;

    R_bin.bin_array{end+1} = Bin;
    R_bin.check = R_bin.check+1;
end
    
events = {};

%% tracking
bin_array = R_bin.bin_array;

del_exit = [];
for i = 1:numel(bin_array)
    
    if isempty(bin_array{i}.tracker)
        % init tracker
        if debug_bin
            tracker = BACF_tracker(im, bin_array{i}.BoundingBox);
        else
            tracker = R_bin.prev_bin{bin_array{i}.label}.tracker;%BACF_tracker(im, bin_array{i}.BoundingBox);
            new_pos = [121, 185];%bin_array{i}.Centroid ;
            tracker = tracker.setPos(new_pos,[]);
            
%             events{end+1}.text = sprintf('')
            
        end
    else
        tracker = bin_array{i}.tracker;
      
    end
    
    [bin_array{i}.tracker, bb] = tracker.runTrack(im);
    bin_array{i}.BoundingBox = bb;
    bin_array{i}.Centroid = [bb(1)+bb(3)/2 bb(2)+bb(4)/2]';
    
%     if abs(bin_array{i}.Centroid(1) - size(im,2)/2) > 30
%         bbox = [1 bb(2) size(im,2) bb(4)];
%         centroid = [size(im,2)/2 bin_array{i}.Centroid(2)];
%         bin_array{i}.tracker = BACF_tracker(im, bbox);
%         bin_array{i}.BoundingBox = bbox;
%         bin_array{i}.Centroid = centroid;
%     end
    
    %% check state
    % set empty or full
    if  ~strcmp(bin_array{i}.state, "empty")
%         Iref = im2single(imread('template_for_c13.jpg'));
%         rect = [ 75.0000  603.0000  150.0000  110.0000];
%        
        Iref = im2single(imresize(imread('pair001_frm1.jpg'),0.5));
        rect = double([10 91 152 108]);
        
        if bin_array{i}.Centroid(2)<313
            Iref = im2single(imresize(imread('pair001_frm1.jpg'),0.5));
            rect = double([10 91 152 108]);
        else
            Iref = im2single(imread('template_for_c13.jpg'));
            rect = [ 75.0000  603.0000  150.0000  110.0000];
        end
        [max_v, ~, ~] = BBS_11(im, bin_array{i}.BoundingBox, Iref, rect);
        if max_v < 0.3
            bin_array{i}.state = "full";
            fprintf('STATE : full : %.2f\n', max_v);
        elseif max_v < 0.50 &&  max_v > 0.25
%             bin_array{i}.state = "empty";
            fprintf('STATE : unspec : %.2f\n', max_v);
        else
            bin_array{i}.state = "empty";
            fprintf('STATE : empty : %.2f\n', max_v);
        end
    end

    if strcmp(bin_array{i}.state, "empty") || bin_array{i}.Centroid(2) > R_bin.limit_exit_y
        R_bin.bin_seq{end+1} = bin_array{i};
        del_exit(end+1) = i;
        R_bin.event{end+1} = sprintf('Bin %d is emptied', bin_array{i}.label);
        events{end+1}.text = sprintf('P%d collects DVI from B%d', ...
            bin_array{i}.belongs_to, bin_array{i}.label);
    end
end

bin_array(del_exit) = [];
R_bin.check_del = -length(del_exit);

R_bin.bin_array = bin_array;


debug_bin = false;


end