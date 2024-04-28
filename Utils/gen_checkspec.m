
clc;
clear;
folders = [''];
%
% trainset = 'sx_1_4_9_10_0.0001_LSTM';
% trainset = 's12_1_4_9_2_0.0001_LSTM';
% trainset = 's5a4_1_4_9_10_0.1_LSTM';
% home = '/Users/yipeiyan/Desktop/FalBench';
home = '/Users/yipeiyan/Desktop/aws_yipei/trainset_s135_delta=10';
% home = '/Users/yipeiyan/Desktop/aws_yipei/trainset_s135_delta=2';

filename = 's3c4_2';
filePattern = fullfile(home,[filename,'*']);
files = dir(filePattern);
folders = files([files.isdir]);
% inputnum = 2;
outputnum = 1;
Totaltime = 23;

% spec1 = 'alw_[0,24](b[t] < 80)';
% spec1 = 'alw_[0,24](b[t] < 20)';
spec1 = 'alw_[0,24](b[t] < 20)';
spec2old = 'alw_[0,18](b[t] > 90 or ev_[0,6](b[t] < 50))';
spec2 = 'alw_[0,18](b[t] > 30 or ev_[0,6](b[t] < -10))'; % not always bt>=20 = have one bt < 20
spec22 = 'alw_[0,18](b[t] < 30 or ev_[0,6](b[t] < -10))';
spec3 = 'not (ev_[6,12](b[t] > 10)) or alw_[18,24](b[t] > -10)';
spec = spec2old;
%}
mkdir([home, '/graph_neg']);
rob_all = {};
rob_neg = {};
rob_zero = {};
rob_pro = {};
rob_neg_range = [];

for j = 1:numel(folders)
    trainset = folders(j).name;
    % FolderPath = fullfile(home, '/Data/trainset/', trainset);
    FolderPath = fullfile(home, trainset);
    inputFilePrefix = 'input_traces_';
    outputFilePrefix = 'output_traces_';

    Y = processCPSData(FolderPath,outputFilePrefix,outputnum);
    % save Y.mat Y;
    rob_list = [];

    %{
Bdata1 = BreachTraceSystem({'temperature', 'humidity'});
time = 0:.1:24; % in hours
temperature = 10 + 15*cos(pi*(time-3)/12+pi)+sin(pi/2*time); % in Celsius deg
humidity = 50 + 10*cos(pi*(time+2)/12)+sin(pi/3*time); % in percents
trace1 = [time' temperature' humidity']; % combine into a trace, column oriented
Bdata1.AddTrace(trace1);

phi1 = STL_Formula('phi', 'alw (temperature[t]<25) and ev_[0, 12] (humidity[t]>50)');
Rphi1 = BreachRequirement(phi1);
rob1 = Rphi1.Eval(Bdata1);
    %}

    % Bdata = BreachTraceSystem({'b'});
    time = 0:1:Totaltime; % in hours
    % Bdata.Sim(0:1:Totaltime);

    phi = STL_Formula('phi',spec);
    % Rphi = BreachRequirement(phi);

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
        if rob <= 0
            rob_neg_range = [rob_neg_range; Y{i}];
        end
        %}
        rob_list = [rob_list,rob];
        disp(i);
    end

    set(gcf, 'Visible', 'off');
    plot(rob_list);
    ylim([-10, 100]);
    xlim([0, 9000]);
    plot_file_path = [home '/graph_neg/' trainset '_plot.png']; % 指定要保存的文件路径和文件名
    saveas(gcf, plot_file_path);
    hist(rob_list);
    ylim([0, 9000]);
    xlim([-10, 100]);
    hist_file_path = [home '/graph_neg/' trainset '_hist.png']; % 指定要保存的文件路径和文件名
    saveas(gcf, hist_file_path);
    xlabel('traces');
    ylabel('rob');
    title('All robs');

    neg = numel(rob_list(rob_list < 0));
    zero = numel(rob_list(rob_list == 0));
    rob_all = [rob_all; trainset; ['all = ' num2str(numel(rob_list))]; '_'];
    rob_neg = [rob_neg; '_'; ['neg = ' num2str(neg)]; '_'];
    rob_zero = [rob_zero; '_'; ['zero = ' num2str(zero)]; '_'];
    pro = neg/numel(rob_list);
    rob_pro = [rob_pro; '_'; ['pro = ' num2str(pro)]; '_'];
    % disp([newline 'num of negative is ' num2str(rob_neg)]);
    % disp([newline 'probability of negative is ' num2str(rob_pro)])
end

csv_file_path = [home '/graph_neg/' filename '_neg_pro.csv'];

% save(['/Users/yipeiyan/Desktop/FalBench/output/rob_neg_range.mat'], 'rob_neg_range');

% 将数组写入 CSV 文件
data = [rob_all, rob_neg, rob_zero, rob_pro];  % 合并两个数组为一个矩阵
writecell(data, csv_file_path);

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
