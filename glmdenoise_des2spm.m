function [names, onsets, durations ] = glmdenoise_des2spm(desmat, tr, stimdur)
% This brief function takes the input used by glmdenoise
% and produces SPM compatible design matrix. 
% These three outputs can be saved and loaded into SPM multiple conditions
% in the batch editor.

for i = 1:size(desmat,2)
    onsets_tr = find(desmat(:,i)==1);
    onsets_seconds = (onsets_tr*tr)-tr;
    onsets{1,i} = onsets_seconds;
    durations{1,i} = stimdur;
    names{1,i} = strcat('cond',num2str(i));
end


