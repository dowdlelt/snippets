function framewise_displacement_displayer()
% The purpose of this script is to display SPM derived movement regressors
% along with framewise displacement (FD).
% You must have SPM in your MatLab path. 
% FD just provides an estimate of total instantenous movement. 
% This is useful to get a quick look at multiple subjects. 
% from Power et al, 2013, doi:  10.1016/j.neuroimage.2011.10.018
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3254728/
%
%FD script is borrowed from the BRAMILA tools package, 
% https://users.aalto.fi/~eglerean/bramila.html 
%

%INSTRUCTIONS:
% Select the motion parameter files you want to save figures of. 
% Recursively selecting them is best, and can be done by filtering
% using ^rp_.*
% you can do this for one 'group' at a time or 
% you can just select all of the motion parameter files and then
% select where you want a motion plot folder to be created 

% Use spm_select to easily get the rp_$fmri_data files produced by
% SPM Realign.  
raw_list = spm_select(Inf, '.*.txt', 'Select Motion Parameter Files');
motionlist = cellstr(raw_list); 

%This sets up things for bramila_framewise_displacement.
cfg.motionparam = ' ';
cfg.prepro_suite = 'spm';
cfg.radius = 50; %default as defined by Power et al
% This number is just an approximation of the distance between the 
% rotation point and the edge of the brain.
% So if someone pitches forward by 2 degrees, this number is used to
% estimate how far the edge of the brain moved. 

% Guess you would change it if you were working with smaller brains perhaps.
%

% Allow the users to select where they would like the motion plot folder.
savedir = spm_select(1,'dir','Select the location to place a motion_plot_folder...');
cd(savedir);
mkdir('motion_plots');
savedir = [savedir, '/motion_plots/'];

figure;
grid on; grid minor; 

% Going to loop through all of the motion parameter files selected to
% plot them. 
for i = 1: size(motionlist, 1);
    
    cfg.motionparam = motionlist{i,1};
    
    [fwd,rms]=bramila_framewiseDisplacement(cfg); %calculate FD using script
    
    x_axis = size(fwd,1); %Get the number of timepoints
    
    raw_motion = load(cfg.motionparam); %get the SPM regressors
    
    %Subplots are used here to keep everything on the same screen. 
    % The y axes for the 6 motion estimates are set from the min and max of
    % those values. 
    % The FD y axes is set to top out at 3 - as that is our voxel size. 
    % The purpose is two fold, anything larger than that is worrisome and
    % This makes it easy to jump through all the subjects and compare
    % quickly. 
    subplot(3,1,1); plot(raw_motion(:,1:3)); axis([0 x_axis min(min(raw_motion(:,1:3))) max(max(raw_motion(:,1:3)))]);
    title('translation'); grid on;
    rots = (57.2958 *raw_motion(:,4:6)); %To convert radians to degrees. 
    subplot(3,1,2); plot(rots); axis([0 x_axis min(min(rots)) max(max(rots))]); 
    title('rotation'); grid on;
    subplot(3,1,3); plot(fwd); title('Framewise Displacement'); axis([0 x_axis 0 3]);
    grid on;
    
    %Thought crosses my mind that I could then use this to create extra 
    %motion regressor things. 
        
    [direc titl ext] = fileparts(cfg.motionparam);
    print([savedir, titl], '-dpng');
    %The above saves the images with the motion regressor as the file name.
end
