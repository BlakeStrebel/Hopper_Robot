function setup_workspace(list)
% Sets up workspace containing raw data, offset data, and averaged data.
% Takes cell list containing .mat file names without the extension
% Example Useage:
%   Navagate to directory containing .mat files of interest
%{
   clear;
   clc;
   list = {'max','s0','s100','s125','s15','s150','s25','s35','s5','s50','s65','s75'};
   setup_workspace(list);
%}
for name = list
    struct = open(strcat(name{1},'.mat'));
    struct = struct.experimental_data;
    assignin('base', name{1}, struct);
    offset = offset_struct(struct);
    assignin('base',strcat('offset_',name{1}),offset);
    avg = average_intrusions(offset);
    assignin('base',strcat('avg_',name{1}),avg);
end