% This program is to train model which is used as CPS.
% It use inputtraces and outputtraces by LSTM.

% To read the datas.
%{
% NetName = 'phi1_1_4_9_15_0.0001_LSTM';
NetName = 'live_2_5_11_9_0.0001_LSTM';
trainset = 'live_2_5_11_9_0.0001_LSTM';
% NetName = 's22_m1_2_4_9_2_0.0001_LSTM';
% trainset = 's22_2_4_9_2_0.0001_LSTM';
home = '/Users/yipeiyan/Desktop/FalBenchGen';
inputnum = 2;
outputnum = 1;
delta = 2;
%}

train_set = ['/Data/trainset_delta=' num2str(delta) '/'];
Model_matlab = ['/Model/Model_matlab_delta=' num2str(delta) '/'];
FolderPath = fullfile(home, train_set, trainset);
inputFilePrefix = 'input_traces_';
outputFilePrefix = 'output_traces_';

X = processCPSData(FolderPath,inputFilePrefix,inputnum);
Y = processCPSData(FolderPath,outputFilePrefix,outputnum);

disp([newline 'Data inputed.']);

%% Train
% Definition the layers of Net.
numFeatures = size(X{1},1);
numResponses = size(Y{1},1);
% numHiddenUnits = 10;

layers = [...
    sequenceInputLayer(numFeatures)% 输入层(特征向量)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')% LSTM层(隐藏单元数,输出,时间顺序)
    % fullyConnectedLayer(50)% 全连接层 50
    % dropoutLayer(0.5)% 丢弃层 50%概率
    fullyConnectedLayer(numResponses)% 回归层
    regressionLayer];

% Definition the options of Net.
% maxEpochs = 10;
% miniBatchSize = 16;
% optimizer = 'adam';

options = trainingOptions(optimizer, ... % optimizer. adam
    'MaxEpochs',maxEpochs, ...  % Epochs.
    'MiniBatchSize',miniBatchSize, ... % Quantity per batch. bsize
    ...'InitialLearnRate',0.01, ...% Learning rate. 0.01
    ...'GradientThreshold',1, ...% Gradient threshold. 1
    ...'Shuffle','never', ...% Keep sorting by sequence length or not （naver）
    'Plots','none', ...% Show progress graph./'training-progress' or 'none'
    'ExecutionEnvironment','auto', ...% Auto use
    'Verbose',1);% Print or not the information to command window.

    % 'InitialLearnRate',0.01, ...% Learning rate. 0.01
    % 'GradientThreshold',1, ...% Gradient threshold. 1
    % 'Shuffle','never', ...% Keep sorting by sequence length or not （naver）

% Train the Net.
disp([newline 'LSTM train start.']);
current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(current_time)]);

%
% train_num = 3;
for i = 1:train_num
    disp(['LSTM ' num2str(i)]);
    rng("shuffle");
    NetName2 = strcat(phi_id,'_',nn_id,'_',num2str(i));
    net = trainNetwork(X,Y,layers,options);
    if train_num == 1
        % model_test_file = fullfile(home, '/Model/Model_matlab/', NetName);
        model_test_file = fullfile(home, Model_matlab, NetName);
    else
        % model_test_file = fullfile(home, '/Model/Model_matlab/', NetName, NetName2);
        model_test_file = fullfile(home, Model_matlab, NetName, NetName2);
    end
    save(model_test_file + ".mat",'net');
end
%}
%{
net = trainNetwork(X,Y,layers,options);
model_test_file = fullfile(home, '/Model/Model_matlab/', NetName);
save(model_test_file + ".mat",'net');
%}

disp([newline 'LSTM train successful.']);
current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(current_time)]);

%% Others
% Change to simulink(not work by LSTM)
% model_test_gensim = gensim(net, 'Name', "test_gensim");
% save_system(model_test_gensim);
% close_system(model_test_gensim);
% analyzeNetwork(net);

% Change to ONN Net. Not work.
% load('/Users/yipeiyan/Desktop/FalBench/Data/test/test_model.mat');
% Onnxfilename = "squeezenet.onnx";
% exportONNXNetwork(squeezenet,Onnxfilename)

% Use 'StatefulPredictExample' to made the LSTM in a simulink.
% Only work on Matlab Online or Matlab intel.
% Select data to make simin(input of simulink).
%{
XTest = X{1000};
numTimeSteps = size(XTest,2);
simin = timetable(repmat(XTest,1,1)','TimeStep',seconds(0.2));

% Open the 'StatefulPredictExample' and replace parts.

open_system('StatefulPredictExample');
set_param('StatefulPredictExample/Stateful Predict','NetworkFilePath',model_test_file);
set_param('StatefulPredictExample', 'SimulationMode', 'Normal');
out = sim('StatefulPredictExample');
%}

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
