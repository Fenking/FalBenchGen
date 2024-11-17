% To read the datas.
%
% NetName = 'phi1_1_4_9_15_0.0001_LSTM';
% NetName = 'live_2_5_11_9_0.0001_LSTM';
% trainset = 'live_2_5_11_9_0.0001_LSTM';
% NetName = 's1_m1_1_4_9_10_0.0001_LSTM';

clc;
clear all;

%
% script_suf = 'cc3a2_1_4_9_10_0.01_LSTM';
home = '/Users/yipeiyan/Desktop/aws_yipei';
script_suf_cos = {'_1_4_9_10_0.0_LSTM','_1_4_9_10_0.01_LSTM','_1_4_9_10_0.05_LSTM','_1_4_9_10_0.1_LSTM'};
phi_id = {'cc5a1d10','cc5a2d10','cc5a3d10','cc5a4d10'};
inputnum = 1;
outputnum = 2;
%}
KMSE_ALL = [];
KMSE_ALL2 = [];
KMSE_ALL_K = [0,0,0,0,0];

for p = 1:4
    script_suf = strcat(phi_id{p}, script_suf_cos{p});
    FolderPath = fullfile(home, '/trainset_cc35a/', script_suf);
    inputFilePrefix = 'input_traces_';
    outputFilePrefix = 'output_traces_';
    
    X = processCPSData(FolderPath,inputFilePrefix,inputnum);
    Y = processCPSData(FolderPath,outputFilePrefix,outputnum);
    
    Y_MSE = {};
    MSE_ALL = 0;
    MSE_ALL2 = 0;
    
    % 定义准确率的误差阈值
    % accuracy_threshold = 10;  % 可以根据需要调整此值
    % spec = 'alw_[0,18](ev_[0,2](not(alw_[0,1](b1[t] >= 9)) or alw_[1,5](b2[t]>= 9)))';
    % phi = STL_Formula('phi',spec);
    % time = 0:1:23;
    
    Y_Accuracy = {};
    Accuracy_ALL = 0;


    for i = 1:5

        MSE_NUM = 0;

        % FolderPath = fullfile(home, '/trainset_cc35a/', script_suf);
        % inputFilePrefix = 'input_traces_';
        % outputFilePrefix = 'output_traces_';
        % 
        % X = processCPSData(FolderPath,inputFilePrefix,inputnum);
        % Y = processCPSData(FolderPath,outputFilePrefix,outputnum);
    
        for k = 1:3
            NetName = strcat(phi_id{p},'_k',num2str(i),script_suf_cos{p});
            NetName2 = strcat(phi_id{p},'_k',num2str(i),'_',num2str(k),'.mat');
            Nname = fullfile(home, '/Model_matlab_cc35a/',NetName, NetName2);
            net = load(Nname).net;
    
            % random_nums = randperm(size(Y,1), 1000);
            % X_test = X(random_nums);
            X_test = X;
            % Y_test = Y(random_nums);
            Y_test = Y;
            Y_trained = predict(net,X_test,'MiniBatchSize',1);
    
            % 初始化准确率计数
            accuracy_count = 0; % 预测准确的样本数
            total_count = 0;    % 总样本数

            [Min,Max] = findMinMax(Y_test);
    
            MSE = [];
            for j = 1:size(Y,1)
                Y_trained_nor = normalized(Max,Min,Y_trained{j});
                Y_test_nor = normalized(Max,Min,Y_test{j});
                % MSE = [MSE, round(mean((Y_trained_nor - Y_test_nor).^2))];
                MSE = [MSE, mean((Y_trained_nor - Y_test_nor).^2)];
                % MSE = [MSE, cellfun(@(trained,test) round(mean((trained - test).^2)),double(Y_trained{j}) Y_test{j})];
                %{
                if outputnum == 1
                    b = Y_trained{i};
                    trace = [time' b'];
                    Bdata = BreachTraceSystem({'b'});
                elseif outputnum == 2
                    b1 = Y_trained{i}(1,:);
                    b2 = Y_trained{i}(2,:);
                    trace = [time' b1' b2'];
                    Bdata = BreachTraceSystem({'b1','b2'});
                end
                Bdata.AddTrace(trace);
                Rphi = BreachRequirement(phi);
                rob = Rphi.Eval(Bdata);
                if rob > 0
                    accuracy_count = accuracy_count + 1;
                end
                total_count = total_count + 1;
                %}
                %{
                % 计算每个元素的绝对误差
                abs_error = abs(Y_trained{j} - Y_test{j});
                % 判断哪些误差在阈值范围内
                correct_predictions = sum(abs_error(:) <= accuracy_threshold);
                % 累计正确预测数和总样本数
                accuracy_count = accuracy_count + correct_predictions;
                total_count = total_count + numel(Y_test{j});
                %}
            end
            %
            Y_MSE = [Y_MSE; MSE];
    
            % 计算百分比形式的损失
            range_squared = (100 - (-100))^2; % 输出范围平方
            normalized_MSE = mean(MSE) / range_squared; % MSE 的百分比表示
    
            MSE_ALL = MSE_ALL + normalized_MSE * 100;
            MSE_ALL2 = MSE_ALL2 + mean(MSE);

            MSE_NUM = MSE_NUM + mean(MSE);
    
            disp(['MSE of net ' NetName2 ' is ' num2str(mean(MSE))]);
            %}
            %{
            % 计算准确率（百分比形式）
            accuracy = (accuracy_count / total_count) * 100;
            Y_Accuracy = [Y_Accuracy; accuracy];
    
            % 累加总体准确率
            Accuracy_ALL = Accuracy_ALL + accuracy;
            disp(['网络 ' NetName2 ' 的准确率是 ' num2str(accuracy, '%.2f') '%']);
            %}
        end

        KMSE_ALL_K(i) = KMSE_ALL_K(i) + MSE_NUM;
        disp(KMSE_ALL_K);

    end
    KMSE_ALL2 = [KMSE_ALL2,MSE_ALL2];
    KMSE_ALL = [KMSE_ALL,MSE_ALL];
    
    disp(['MSE_ALL：' num2str(MSE_ALL) ]);
    disp(['MSE_ALL2：' num2str(MSE_ALL2) ]);
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


function data = normalized(max_val, min_val, Y)
    data = (Y - min_val) / (max_val - min_val);
end


function [global_min, global_max] = findMinMax(data)
    global_min = inf;
    global_max = -inf;

    % 遍历每个 cell
    for i = 1:length(data)
        current_data = data{i}; % 取出当前 cell 的数据

        % 确保是 single 类型的数据
        if isa(current_data, 'double')
            % 更新最小值和最大值
            global_min = min(global_min, min(current_data, [], 'all'));
            global_max = max(global_max, max(current_data, [], 'all'));
        end
    end
end
