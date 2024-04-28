% To read the datas.
%
% NetName = 'phi1_1_4_9_15_0.0001_LSTM';
% NetName = 'live_2_5_11_9_0.0001_LSTM';
% trainset = 'live_2_5_11_9_0.0001_LSTM';
% NetName = 's1_m1_1_4_9_10_0.0001_LSTM';

clc;
clear all;

%
script_suf = 's3_1_4_9_10_0.0001_LSTM';
home = '/Users/yipeiyan/Desktop/FalBench';
script_suf_cos = '_1_4_9_10_0.0001_LSTM';
phi_id = 's3';
inputnum = 1;
outputnum = 1;
%}

Y_MSE = {};
for i = 1:15

    FolderPath = fullfile(home, '/Data/trainset/', script_suf);
    inputFilePrefix = 'input_traces_';
    outputFilePrefix = 'output_traces_';

    X = processCPSData(FolderPath,inputFilePrefix,inputnum);
    Y = processCPSData(FolderPath,outputFilePrefix,outputnum);

    NetName = strcat(phi_id,'_m',num2str(i),script_suf_cos);
    Nname = fullfile(home, '/Model/Model_matlab3/', [NetName,'.mat']);
    net = load(Nname).net;

    random_nums = randperm(size(Y,1), 100);
    X_test = X(random_nums);
    Y_test = Y(random_nums);
    Y_trained = predict(net,X_test,'MiniBatchSize',1);
    MSE = [];
    for j = 1:100
        MSE = [MSE, round(mean((Y_trained{j} - Y_test{j}).^2))];
        % MSE = [MSE, cellfun(@(trained,test) round(mean((trained - test).^2)),double(Y_trained{j}) Y_test{j})];
    end
    Y_MSE = [Y_MSE; MSE];
    disp(['MSE of net ' num2str(i) ' is ' num2str(mean(MSE))]);
end


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