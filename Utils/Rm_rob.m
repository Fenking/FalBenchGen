
clc;
clear;
folders = ['1'];
%
% trainset = 'sx_1_4_9_10_0.0001_LSTM';
% trainset = 's12_1_4_9_2_0.0001_LSTM';
% trainset = 's5a4_1_4_9_10_0.1_LSTM';
% home = '/Users/yipeiyan/Desktop/FalBench';
home = '/Users/yipeiyan/Desktop/aws_yipei/trainset_skt_delta=15-20';
% home = '/Users/yipeiyan/Desktop/aws_yipei/trainset_s135_delta=2';

newname = 's3kc1';
mkdir([home '/' newname]);
filename = 's3kc1_2_';
filePattern = fullfile(home,[filename,'*']);
files = dir(filePattern);
folders = files([files.isdir]);
% inputnum = 2;
outputnum = 1;
Totaltime = 23;
difficulty = 0;
neg = 800;
% a2=1326;a3=866;a4=800 c2=1080 c3=865 c4=745
zero = 0;
% a2=9;a3=46; c2=0 c3=47 c4=96

input_path = fullfile(home, [newname '/input_traces_1']);
output_path = fullfile(home, [newname '/output_traces_1']);

% spec1 = 'alw_[0,24](b[t] < 80)';
% spec1 = 'alw_[0,24](b[t] < 20)';
spec1 = 'alw_[0,24](b[t] < 20)';
spec2old = 'alw_[0,18](b[t] > 90 or ev_[0,6](b[t] < 50))';
spec2 = 'alw_[0,18](b[t] > 30 or ev_[0,6](b[t] < -10))'; % not always bt>=20 = have one bt < 20
spec22 = 'alw_[0,18](b[t] < 30 or ev_[1,6](b[t] < -10))';
spec3 = 'not (ev_[6,12](b[t] > 10)) or alw_[18,24](b[t] > -10)';
spec = spec2;
%}


for j = 1:1
    trainset = folders(j).name;
    % FolderPath = fullfile(home, '/Data/trainset/', trainset);
    FolderPath = fullfile(home, trainset);
    inputFilePrefix = 'input_traces_';
    outputFilePrefix = 'output_traces_';

    Y = processCPSData(FolderPath,outputFilePrefix,outputnum);
    Y_print = processCPSData2(FolderPath,outputFilePrefix);
    X_print = processCPSData2(FolderPath,inputFilePrefix);
    Trace_num = numel(Y);
    if difficulty == 0.01
        neg_num = (neg - (Trace_num-zero)*difficulty)/(1-difficulty);
    else
        disp(difficulty);
    end

    % save Y.mat Y;
    rob_neg_range = 0;
    inputtrace_list = {};
    outputtrace_list = {};

    % Bdata = BreachTraceSystem({'b'});
    time = 0:1:Totaltime; % in hours
    % Bdata.Sim(0:1:Totaltime);

    phi = STL_Formula('phi',spec);
    % Rphi = BreachRequirement(phi);

    %
    for i = 1:numel(Y)
        % rob = 20 - max(Y{i});
        %
        b = Y{i};
        trace = [time' b'];
        Bdata = BreachTraceSystem({'b'});
        Bdata.AddTrace(trace);
        % Bdata.P.traj{1,1}.X = b;
        % Bdata.P.Xf = Bdata.P.Xf(1,end);
        % Bdata.P.epsi = Bdata.P.epsi(1,end);%
        % Bdata.P.pts = Bdata.P.pts(1,end);
        % Bdata.P.traj = Bdata.P.traj(1,end);%
        % Bdata.P.traj_ref = 1;
        Rphi = BreachRequirement(phi);
        rob = Rphi.Eval(Bdata);
        r = rand;
        if rob < 0
            if difficulty == 0.01
                if r > neg_num/neg
                    inputtrace_list = [inputtrace_list; X_print{i}];
                    outputtrace_list = [outputtrace_list; Y_print{i}];
                else
                    % disp(i)
                    rob_neg_range = rob_neg_range + 1;
                end
            elseif difficulty == 0
                rob_neg_range = rob_neg_range + 1;
            else
                inputtrace_list = [inputtrace_list; X_print{i}];
                outputtrace_list = [outputtrace_list; Y_print{i}];
            end
        elseif rob == 0
            rob_neg_range = rob_neg_range + 1;
        else
            inputtrace_list = [inputtrace_list; X_print{i}];
            outputtrace_list = [outputtrace_list; Y_print{i}];
        end
        %
        disp(i);
    end
    %}
    disp(rob_neg_range)


    fileID1 = fopen(input_path, 'w');
    fileID2 = fopen(output_path, 'w');

    for i = 1:numel(inputtrace_list)
        % line_str = sprintf('%.5f, ', X(i, :));
        % line_str = ['[', line_str(1:end-2), '];'];
        fprintf(fileID1, '%s\n', inputtrace_list{i});
        fprintf(fileID2, '%s\n', outputtrace_list{i});
    end
    fclose(fileID1);
    fclose(fileID2);
    
end


% save(['/Users/yipeiyan/Desktop/FalBench/output/rob_neg_range.mat'], 'rob_neg_range');

% 将数组写入 CSV 文件
%% Function

function traces = processCPSData(folder, prefix, num)
    % 构建带有前缀的文件路径
    filePattern = fullfile(folder,[prefix,'*']);
    files = dir(filePattern);

    % 初始化数据
    % data = cell(numel(files),1);
    traces = {};

    % 逐一读取文件
    for i = 1:numel(files)
        filePath = fullfile(files(i).folder, files(i).name);
        fileContent = fileread(filePath);

        % 将文件内容转换为一行一行的列表
        data = str2num(fileContent);
        traces = [traces; num2cell(data,2)];
        %
        for n = 1:size(traces, 1)
            traces_row = {};
            for j = 1:num:numel(traces{n})
                traces_col = {};
                for k = 1:num
                    data = traces{n}(j-1+k);
                    traces_col = [traces_col; num2cell(data)];
                end
                traces_row = [traces_row, traces_col];
            end
            traces{n} = cell2mat(traces_row);
        end
    end
    %}
end


function traces = processCPSData2(folder, prefix)
    % 构建带有前缀的文件路径
    filePattern = fullfile(folder,[prefix,'*']);
    files = dir(filePattern);

    % 初始化数据
    % data = cell(numel(files),1);
    traces = {};

    % 逐一读取文件
    for i = 1:numel(files)
        filePath = fullfile(files(i).folder, files(i).name);
        fileContent = fileread(filePath);

        % 将文件内容转换为一行一行的列表
        % data = str2num(fileContent);
        lines = regexp(fileContent, '\r?\n', 'split');
        lines = lines(~cellfun('isempty', lines))';  % 过滤空行
        traces = [traces; lines];
        %
    end
    %}
end
