% To read the datas.
%


clc;
clear all;

%
% script_suf = 's3_1_4_9_10_0.0001_LSTM';
home1 = '/Users/yipeiyan/Desktop/aws_yipei/Model_matlab_s135_delta=10';
home2 = '/Users/yipeiyan/Desktop/aws_yipei/trainset_s135_delta=10';
spec1 = 'alw_[0,24](b[t] < 20)';
spec2old = 'alw_[0,18](b[t] > 90 or ev_[0,6](b[t] < 50))';
spec2 = 'alw_[0,18](b[t] > 30 or ev_[0,6](b[t] < -10))'; % not always bt>=20 = have one bt < 20
spec22 = 'alw_[0,18](b[t] < 30 or ev_[0,6](b[t] < -10))';
spec3 = 'not (ev_[6,12](b[t] > 10)) or alw_[18,24](b[t] > -10)';
% script_suf_cos = '_1_4_9_10_0.0001_LSTM';
% phi_id = 's3';
inputnum = 2;
% outputnum = 1;
Totaltime = 23;
filename = 's3c4';
addname = '_delta=10';
spec = spec2old;
%}


% time = 0:1:Totaltime;
% phi = STL_Formula('phi',spec);

ModelfilePattern = fullfile(home1,[filename,'*']);
Modelfiles = dir(ModelfilePattern);
Modelfolders = Modelfiles([Modelfiles.isdir]);

TracefilePattern = fullfile(home2,[filename,'*']);
Tracefiles = dir(TracefilePattern);
Tracefolders = Tracefiles([Tracefiles.isdir]);

Y_is_fla = [];
Y_have_fla = [];

for i = 1:numel(Tracefolders)
    disp([newline Tracefolders(i).name 'start'])
    FolderPath = fullfile(home2, Tracefolders(i).name);
    inputFilePrefix = 'input_traces_';
    outputFilePrefix = 'output_traces_';

    X = processCPSData(FolderPath,inputFilePrefix,inputnum);
    % Y = processCPSData(FolderPath,outputFilePrefix,outputnum);
    MT = numel(Modelfolders)/numel(Tracefolders);

    for j = 1:MT
        disp([newline num2str((i-1)*MT+j) ' ' Modelfolders((i-1)*MT+j).name 'start'])
        NetName = fullfile(home1, Modelfolders((i-1)*MT+j).name);
        Net_info = dir(NetName);
        Nets = Net_info(~[Net_info.isdir]);
        for k = 1:numel(Nets)
            Nname = fullfile(Nets(k).folder, Nets(k).name);
            net = load(Nname).net;
            Y_trained = predict(net,X,'MiniBatchSize',1);
            rob_list = [];

            time = 0:1:Totaltime;
            phi = STL_Formula('phi',spec);
            
            for num = 1:numel(Y_trained)
                % rob = 20 - max(Y_trained{num});
                % if num == numel(X)
                disp(num)
                % end
                %
                b = double(Y_trained{num});
                trace = [time' b'];
                Bdata = BreachTraceSystem({'b'});
                Bdata.AddTrace(trace);
                Rphi = BreachRequirement(phi);
                rob = Rphi.Eval(Bdata);
                %}
                rob_list = [rob_list, rob];
            end
            has_negative = any(rob_list <= 0);
            if has_negative
                negative_count = sum(rob_list <= 0);
                Y_is_fla = [Y_is_fla; Nets(k).name];
                Y_have_fla = [Y_have_fla; negative_count];
            end
            disp([newline 'k' Nets(k).name ' over'])
        end
        % Nname = fullfile('/Model/Model_matlab3/', [NetName,'.mat']);
        disp([newline num2str((i-1)*MT+j) ' ' Modelfolders((i-1)*MT+j).name 'over'])
    end
    disp([newline Tracefolders(i).name 'over'])
end

save(['/Users/yipeiyan/Desktop/FalBench/output/' [filename addname] '.mat'], 'Y_is_fla', 'Y_have_fla');


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