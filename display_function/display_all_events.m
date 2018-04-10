
R_11.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\11';
R_11.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_11.mat';
R_2.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_2.mat';

R_2.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\2';

R_11.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_11.mat';

R_11.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\11';
R_13.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_13.mat';

R_13.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\13';
R_9.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_9.mat';

R_9.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\9';

R_5.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_5.mat';

R_5.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\5';


load(R_9.event_save_file);
ev9 = event_struct;

load(R_2.event_save_file);
ev2 = event_struct;

load(R_11.event_save_file);
ev11 = event_struct;

load(R_13.event_save_file);
ev13 = event_struct;


ev9{5000} = {};
ev2{5000} = {};
ev5{5000} = {};
ev11{5000} = {};
ev13{5000} = {};
%%

camera_no = 9;

start_frame = 305;

cur_frame = start_frame;

font_size = 30;
pad = 15;
% cur = numel(All_Event);

filename = '../all_1.avi';
v = VideoWriter(filename);
open(v);
Event ={};

while true
    % get all event of current frame;
    % 9
    ev_frame = ev9{cur_frame};
    for l = 1:numel(ev_frame)
       if ~isempty(ev_frame) 
           Event{end+1}.text = ev_frame{l};
           Event{end}.camera = 9;
           Event{end}.frame = cur_frame;
       end
    end
    ev_frame = ev13{cur_frame};
    for l = 1:numel(ev_frame)
       if ~isempty(ev_frame) 
           Event{end+1}.text = ev_frame{l};
           Event{end}.camera = 13;
           Event{end}.frame = cur_frame+6;
       end
    end
    
    ev_frame = ev2{cur_frame};
    for l = 1:numel(ev_frame)
       if ~isempty(ev_frame) 
           Event{end+1}.text = ev_frame{l};
           Event{end}.camera = 2;
           Event{end}.frame = cur_frame;
       end
    end
    
    ev_frame = ev11{cur_frame};
    for l = 1:numel(ev_frame)
       if ~isempty(ev_frame) 
           Event{end+1}.text = ev_frame{l};
           Event{end}.camera = 11;
           Event{end}.frame = cur_frame;
       end
    end
      
    cur = numel(Event);

    
    h = 1040;
    
    if cur_frame == 2160
       break 
    end
    
    if cur_frame < 1020 % 9
        filename = [R_9.frame_save_folder '\' sprintf('%04d.jpg',cur_frame)];
        im = imread(filename);  
        camera_no = 9;
    elseif cur_frame < 1242 % 2
        filename = [R_2.frame_save_folder '\' sprintf('%04d.jpg',cur_frame)];
        im = imread(filename);  
        camera_no = 2;
    elseif cur_frame < 1300 % 5
        filename = [R_5.frame_save_folder '\' sprintf('%04d.jpg',cur_frame)];
        im = imread(filename);
        camera_no = 5;
    elseif cur_frame<1631 % 
        filename = [R_11.frame_save_folder '\' sprintf('%04d.jpg',cur_frame)];
        im = imread(filename);
        camera_no = 11;
    else 
        filename = [R_13.frame_save_folder '\' sprintf('%04d.jpg',cur_frame)];
        im = imread(filename);
        camera_no = 13;
    end
    
    col =  800;
    row = 1040;
    if camera_no == 2 || camera_no == 5 || camera_no == 13
        rw = row / size(im, 1);
        rh = col / size(im,2);
        scale = min([rw, rh]);
        imn = imresize(im, scale);
        imtmp = uint8(ones(1040, 800, 3)*255);
        imtmp(1:size(imn, 1), 1:size(imn, 2), :) = imn;
        im = imtmp;
    else
        im = imresize(im, [1040 800]);
    end
    
       
    im1 = uint8(ones(h, 150, 3) * 255);
    
    im2 = uint8(ones(h, 100, 3) * 255);
    
    im3 = uint8(ones(h, 400, 3) * 255);
    
    no = 8;
    per_h = round(2/3 * h / no);
    
    for i = 1:no
        
        if cur <=0
            break;
        end
        
        eve = Event{cur};
        
        x = pad;
        y = i*per_h;
        
        text = eve.text;
        if strcmp(text(4:8), 'goest')
           text(4:8) = 'goes ';
           eve.text = text;
        end
        
        im1 = insertText(im1, [x y], sprintf('%04d',eve.frame),'FontSize', 25);
        im2 = insertText(im2, [x y], sprintf('%d',eve.camera),'FontSize', 25);
        if isfield(eve, 'color')
            im3 =insertText(im3, [x y], eve.text, 'BoxColor', eve.color, 'FontSize', 20);
        else
            im3 =insertText(im3, [x y], eve.text, 'FontSize', 22 );
        end
        % im2 =insertText(im3, [x y], eve.text, 'BoxColor', eve.color, 'FontSize', 22 );
        
        cur = cur - 1;
        
    end
     im_comb = cat(2, im, im1, im2, im3);
  

    header1 = uint8(ones(70, size(im,2), 3) * 255);
    header2 = uint8(ones(70, size(im1,2) + size(im2,2)+size(im3,2), 3) * 255);
    
    header1 = insertText(header1, [5 5], sprintf('Camera %d : %04d', camera_no, cur_frame), 'FontSize', font_size);
        header2 = insertText(header2, [5 5], 'Frame', 'FontSize', font_size);

    header2 = insertText(header2, [5+size(im1,2) 5], 'Cam', 'FontSize', font_size);
    header2 = insertText(header2, [5+size(im1,2) + size(im2,2) 5], 'Info', 'FontSize', font_size);
    
    header = cat(2, header1, header2);
    
    insertText(header, [10 3], sprintf('Camera %d', camera_no), 'FontSize', font_size);
    
    
    imm = cat(1, header, im_comb);
    
    figure(1);imshow(imm); drawnow;
    
    writeVideo(v, imm);
    
    cur_frame = cur_frame + 1;
end


for j = 1:60
    im_black = uint8(zeros(size(imm, 1), size(imm,2), 3))*255;
    writeVideo(v, im_black); 
end

% close(v);

