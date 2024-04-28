%% Add path
% clear;
close all;
clc;
% replace this path with yours
% home = '/Users/yipeiyan/Desktop/FalBench';
% addpath(genpath('/Users/yipeiyan/Desktop/FalBench'));
% addpath(genpath('/Users/yipeiyan/Desktop/AI-CPS-Benchmark/tools/breach'));
InitBreach;
addpath(genpath(home));

%% Add BreachSignalGen

%{
NetName = 's1_m3_1_4_9_10_0.0001_LSTM';
inputnum = 2;
outputnum = 2;
spec = 'alw_[0,30](b1[t]<90 or ev_[0,5](b2[t]> 800))';
Totaltime = 29.0;
inputrange = [[0.0, 10.0];[0.0, 10.0]];
nn_id = 'm3';
phi_id = 's1';
delta = 2;
%}
% train_num = numel(dir(fullfile(home, '/Model/Model_matlab/', NetName))) - 2;

Model_matlab = ['/Model/Model_matlab_delta=' num2str(delta) '/']; 

if train_num == 0
    train_num = 1;
end
for x = 1:train_num

    if train_num == 1
        % name = fullfile(home, '/Model/Model_matlab/', [NetName,'.mat']);
        name = fullfile(home, Model_matlab, [NetName,'.mat']);
    else
        NetName2 = strcat(phi_id,'_',nn_id,'_',num2str(x));
        % name = fullfile(home, '/Model/Model_matlab/', NetName, [NetName2,'.mat']);
        name = fullfile(home, Model_matlab, NetName, [NetName2,'.mat']);
    end
    disp([newline 'breach test the ' NetName]);
    % name = '/Users/yipeiyan/Desktop/FalBench/Data/test/6/test_model.mat';
    net = load(name);
    sg = traces_signal_gen(inputnum,outputnum,net,Totaltime);
    B = BreachSignalGen(sg);
    B.SetTime(0:1:Totaltime);
    %
    for i = 1:size(inputrange,1)
        T = inputrange(i,:);
        Params = {};
        Ranges = [];
        for j = 1:round((Totaltime+1)/6)
            paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
            Params{1,j} = paramName;
            Ranges = [Ranges; T(1) T(2)];
        end
        B.SetParamRanges(Params, Ranges);% Can be inputed multiple.
    end
    %}
    %测试用于上部分
    %{
    T(1) = 0;
    T(2) = 10;
    B.SetParamRanges( {'u0_0', 'u0_1', 'u0_2', 'u0_3', 'u0_4', ...
        'u1_0', 'u1_1', 'u1_2', 'u1_3', 'u1_4'}, ...
        [T(1) T(2); T(1) T(2); T(1) T(2); T(1) T(2); T(1) T(2); ...
        T(1) T(2); T(1) T(2); T(1) T(2); T(1) T(2); T(1) T(2)])
        %}

    % spec = 'alw_[0,24](b[t] < 80)';
    phi = STL_Formula('phi',spec);
    % R = BreachRequirement(phi);

    if train_num == 1
        breach_test_data = fullfile(home, '/Model/breachDate/', ['Data_', NetName]);
    else
        NetName2 = strcat(phi_id,'_',nn_id,'_',num2str(x));
        breach_test_data = fullfile(home, '/Model/breachDate/', ['Data_', NetName], NetName2);
    end

    % save(breach_test_data + ".txt",'num_sim','time','obj_best','-ascii');
    fid = fopen([breach_test_data, '.txt'], 'w');


    %% Solve problem cmaes
    % Pb = FalsificationProblem(B,R);
    % Pb.max_obj_eval = 300;
    % Pb.setup_cmaes();
    % Pb.solve();

    trials = 30;% 10 20 30
    falsified = [];
    time = [];
    obj_best = [];
    num_sim = [];

    disp([newline 'cmaes breach start.']);
    current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    disp(['Time Now: ' datestr(current_time)]);

    for n = 1:trials
    	falsif_pb = FalsificationProblem(B,phi);
        % falsification budget
    	falsif_pb.max_time = 600;
        falsif_pb.max_obj_eval = 1000;% 1000
        % specific falsification algorithm
    	falsif_pb.setup_solver('cmaes');
    	falsif_pb.solve();
    	if falsif_pb.obj_best < 0
    		falsified = [falsified;1];
    	else
    		falsified = [falsified;0];
    	end
    	num_sim = [num_sim;falsif_pb.nb_obj_eval];
    	time = [time;falsif_pb.time_spent];
    	obj_best = [obj_best;falsif_pb.obj_best];
    end

    successful_runs = find(obj_best<0);
    SR = numel(successful_runs);
    avetime = sum(time(successful_runs))/numel(successful_runs);
    avesim = sum(num_sim(successful_runs))/numel(successful_runs);

    fprintf(fid, 'breach by cmaes:\n');
    fprintf(fid, 'SR = %.2f\n', SR);
    fprintf(fid, 'avetime = %.2f\n', avetime);
    fprintf(fid, '#sim = %.2f\n\n', avesim);

    fprintf(fid, 'num_sim = %d\n', num_sim);
    fprintf(fid, 'time = %.8f\n', time);
    fprintf(fid, 'obj_best = %.8f\n', obj_best);

    %% Solve problem simulannealbnd

    % trials = 30;
    falsified = [];
    time = [];
    obj_best = [];
    num_sim = [];

    disp([newline 'simulannealbnd breach start.']);
    current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    disp(['Time Now: ' datestr(current_time)]);

    for n = 1:trials
    	falsif_pb = FalsificationProblem(B,phi);
        % falsification budget
    	falsif_pb.max_time = 600;
        falsif_pb.max_obj_eval = 1000;
        % specific falsification algorithm
    	falsif_pb.setup_solver('simulannealbnd');
    	falsif_pb.solve();
    	if falsif_pb.obj_best < 0
    		falsified = [falsified;1];
    	else
    		falsified = [falsified;0];
    	end
    	num_sim = [num_sim;falsif_pb.nb_obj_eval];
    	time = [time;falsif_pb.time_spent];
    	obj_best = [obj_best;falsif_pb.obj_best];
    end

    successful_runs = find(obj_best<0);
    SR = numel(successful_runs);
    avetime = sum(time(successful_runs))/numel(successful_runs);
    avesim = sum(num_sim(successful_runs))/numel(successful_runs);

    fprintf(fid, '\n\nbreach by simulannealbnd:\n');
    fprintf(fid, 'SR = %.2f\n', SR);
    fprintf(fid, 'avetime = %.2f\n', avetime);
    fprintf(fid, '#sim = %.2f\n\n', avesim);

    fprintf(fid, 'num_sim = %d\n', num_sim);
    fprintf(fid, 'time = %.8f\n', time);
    fprintf(fid, 'obj_best = %.8f\n', obj_best);

    %% solve by MCTS

    % trials = 30;
    falsified = [];
    time = [];
    obj_best = [];
    num_sim = [];

    disp([newline 'MCTS start.']);
    current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    disp(['Time Now: ' datestr(current_time)]);

    N_max =1000; %total MCTS
    T_playout = 40; 
    scalar = 0.2;
    if inputnum == 1
        partitions = 3; %or [2 2] if input_num = 2
    else
        partitions = [2 2];
    end
    % Totaltime = 24;  % total time (not sure if this is Totaltime)
    controlpoints = round((Totaltime+1)/6); 
    hill_climbing_by = 'cmaes';
    input_num = size(inputrange,1);

    for n = 1:trials
        start_mcts = tic;
        m = MCTS(sg, N_max, scalar, phi, Totaltime, controlpoints, hill_climbing_by, T_playout, input_num, inputrange, partitions);
        time_mcts = toc(start_mcts);

        if min(m.obj_log) < 0
            falsified = [falsified;1];
        else
            falsified = [falsified;0];
        end
        num_sim = [num_sim; numel(m.obj_log)];
        time = [time; time_mcts];
        obj_best = [obj_best; min(m.obj_log)];
    end

    successful_runs = find(obj_best<0);
    SR = numel(successful_runs);
    avetime = sum(time(successful_runs))/numel(successful_runs);
    avesim = sum(num_sim(successful_runs))/numel(successful_runs);

    fprintf(fid, '\n\nbreach by MCTS:\n');
    fprintf(fid, 'SR = %.2f\n', SR);
    fprintf(fid, 'avetime = %.2f\n', avetime);
    fprintf(fid, '#sim = %.2f\n\n', avesim);

    fprintf(fid, 'num_sim = %d\n', num_sim);
    fprintf(fid, 'time = %.8f\n', time);
    fprintf(fid, 'obj_best = %.8f\n', obj_best);

    %% Solve problem random

    num = 1000;
    rob_list = [];

    % trials = 30;
    falsified = [];
    time = [];
    obj_best = [];
    num_sim = [];

    disp([newline 'random breach start.']);
    current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    disp(['Time Now: ' datestr(current_time)]);
    
    for n = 1:trials
        time_random = tic;
        for k = 1:num
            rob_list = [rob_list;k];
            for i = 1:size(inputrange,1)
                T = inputrange(i,:);
                Params = {};
                rands = [];
                for j = 1:round((Totaltime+1)/6)
                    paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
                    Params{1,j} = paramName;
                    rands = [rands, T(1)+(T(2)-T(1))*rand()];
                    % disp(rands)
                end
                B.SetParam(Params,rands);
            end
            B.Sim(0:1:Totaltime);
            rob = B.CheckSpec(phi);
            rob_list = [rob_list;rob];
            if rob < 0
                % break_list = [break_list, k];
                break
            end
        end
        end_time = toc(time_random);
        num_sim = [num_sim;k];
        time = [time;end_time];
    	obj_best = [obj_best;rob];
    end

    successful_runs = find(obj_best<0);
    SR = numel(successful_runs);
    avetime = sum(time(successful_runs))/numel(successful_runs);
    avesim = sum(num_sim(successful_runs))/numel(successful_runs);

    fprintf(fid, '\n\nbreach by random:\n');
    fprintf(fid, 'SR = %.2f\n', SR);
    fprintf(fid, 'avetime = %.2f\n', avetime);
    fprintf(fid, '#sim = %.2f\n\n', avesim);

    fprintf(fid, 'num_sim = %d\n', num_sim);
    fprintf(fid, 'time = %.8f\n', time);
    fprintf(fid, 'obj_best = %.8f\n', obj_best);
    fprintf(fid, '\n');
    fprintf(fid, 'rb = %.8f\n', rob_list);

    disp([newline 'breach end.']);
    current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    disp(['Time Now: ' datestr(current_time)]);

    %% others

    % sendEmail();
    fclose(fid);
end
