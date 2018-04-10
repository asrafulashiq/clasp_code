
global scale;

%% file names
R_11.filename = fullfile(basename, '11'); % input file
R_11.file_to_save =  fullfile('..',file_number, [file_number '_cam11_vars'  '.mat']); % file to save variables
R_11.write_video_filename = fullfile('..',file_number, ['cam11_output_' file_number '.avi']); % file to save video

%% event
R_11.Event = zeros(0,4); % [id people_index bin_index count]; id: 3:potential stealing
%% frame info

x = dir(R_11.filename);
len = numel(x);
lastfilename = split(x(len).name,'.');
R_11.end_frame = str2num(lastfilename{1});

R_11.max_flow = 200000;

R_11.R_peope.current_frame = 0;
R_11.R_bin.current_frame = 0;

% 115    75   365   869
% [ 230  150  730  1738]*scale

R_11.R_bin.event = {};
R_11.R_people.event = {};
R_11.recent_events = {};

R_11.event_struct = {};
R_11.event_save_file = 'E:\alert_remote_code\airport_security\camera9\events\9A\events_11.mat';
R_11.is_save_event = true;

R_11.frame_save_folder = 'E:\alert_remote_code\airport_security\camera9\events\9A\11';
R_11.is_save_frame = true;

%% people region
% R_11.R_people.reg = [570 1080-120 300 1800] * scale;
R_11.R_people.reg = [289 480 75 960] * 2 * scale;

R_11.R_people.people_seq = {}; % store exit people info
R_11.R_people.people_array = {}; % current people info
R_11.R_people.label = 1; % people label

% set initial people detector properties
R_11.R_people.min_allowed_dis = 200 * scale;
R_11.R_people.limit_area = 8000 * 4 * scale^2;
R_11.R_people.limit_area_med = 12000 * 4 *scale^2;
R_11.R_people.limit_init_area = 15000 * 4 *  scale^2;
R_11.R_people.limit_init_max_area = 40000 * 4 *  scale^2;
R_11.R_people.limit_max_width = 450 *  scale;
R_11.R_people.limit_max_height = 600 * scale;
R_11.R_people.half_y = 1000 * scale;
R_11.R_people.limit_exit_x1 = 240 * scale;
R_11.R_people.limit_exit_y2 = 600 * scale;
R_11.R_people.limit_exit_x2 = 220 * scale;
R_11.R_people.limit_init_y = 950 * scale;
R_11.R_people.limit_init_x = 300 * scale;

R_11.R_people.limit_exit_y = 820 * 2 * scale;
R_11.R_people.limit_exit_x = 2 * scale;
R_11.R_people.threshold_img = 15;
R_11.R_people.limit_flow = 1500;
R_11.R_people.limit_exit_max_area = 10000 * 4 * scale^2;
R_11.R_people.limit_flow_mag = 0.05;
R_11.R_people.half_x = 315 * scale;
R_11.R_people.limit_max_displacement = 300 * scale;
%% belt/bin region
% R_11.R_bin.reg = [230 550 150-140 1920] * scale ;
R_11.R_bin.reg = [115 288  75 960] * 2 * scale;
R_11.R_bin.label = 1;
R_11.R_bin.bin_seq = {};
R_11.R_bin.bin_array={};
R_11.R_bin.threshold = 20; 

R_11.R_bin.limit_exit_y = 820 * 2 * scale;


R_11.R_bin.limit_distance = 220 * scale;
R_11.R_bin.threshold_img = 15;
R_11.R_bin.limit_area = 16000 * 4 * scale^2;
R_11.R_bin.limit_min_area = 8000 * 4 * scale^2;
R_11.R_bin.limit_area2 = 20000 * 4 * scale^2;
R_11.R_bin.limit_max_area = 40000 * 4 * scale^2;
R_11.R_bin.limit_init_y = 250 * 2 * scale; 
R_11.R_bin.solidness_ratio = 31;
R_11.R_bin.area_ratio = 2;

R_11.R_bin.k_distort = -0.2;
%% angle of rotation
R_11.rot_angle = 90;


%% background of camera 
R_11.im_background = get_background(R_11.filename, 10);

% get people background
im = R_11.im_background;
im = imresize(im,scale);%original image
im = imrotate(im, R_11.rot_angle);

R_11.R_people.im_back = im(R_11.R_people.reg(3):R_11.R_people.reg(4),R_11.R_people.reg(1):R_11.R_people.reg(2),:);
R_11.R_bin.im_back = im(R_11.R_bin.reg(3):R_11.R_bin.reg(4),R_11.R_bin.reg(1):R_11.R_bin.reg(2),:);




