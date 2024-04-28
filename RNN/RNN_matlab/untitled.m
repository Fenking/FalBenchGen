%{
fid = fopen('hello_world_script.sh', 'w');
fprintf(fid, '#!/bin/sh\n');
for n = 1:inputnum
  fprintf(fid, 'echo "hello world"\n');
end
fclose(fid);
%}
clear;
disp([newline 'Data inputed.']);

disp([newline 'LSTM train start.']);
current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(current_time)]);

disp([newline 'LSTM train over.']);
current_time = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(current_time)]);


% 定义你的序列
sequence = [1 2 3 4 5 6 7 8];
traces = {};
% 设置处理间隔
n = 2;

% 获取序列长度

% 进行特殊循环处理
for i = 1:n:numel(sequence)
    traces_cow = {};
    for j = 1:n
        data = sequence(i-1+j);
        traces_cow = [traces_cow; num2cell(data)];
    end
    traces = [traces, traces_cow];
end
traces = {traces};
%{
% 定义你的矩阵
matrix = reshape(1:54, 9, 6);

% 设置处理间隔（每组3行一循环）
n_rows_per_group = 3;

% 获取矩阵的行数和列数
[num_rows, num_cols] = size(matrix);

% 计算总共有多少组
num_groups = num_rows / n_rows_per_group;

% 进行特殊循环处理
for group = 1:num_groups
    % 获取当前组的行索引
    row_indices = (group-1) * n_rows_per_group + (1:n_rows_per_group);
    
    % 获取当前组的子矩阵
    sub_matrix = matrix(row_indices, :);
    
    % 在这里执行你的处理逻辑，例如打印子矩阵
    disp(sub_matrix);
end
%}
p = zeros(1,22);

% 设置初始变量
% u0_0 = 1;
% u0_1 = 2;
% u0_2 = 3;
% u0_3 = 4;

% 定义循环范围
num = 2;

% 循环创建新变量
for i = 1:num
    % 创建新变量名
    for j = 1:4
        new_var_name = sprintf('u%d_%d', i-1, j-1);
        ooo = num2str(j*i);
    % 使用 eval 赋值
        eval([new_var_name '=' ooo]);
        % disp([new_var_name ' = ' num2str(eval(new_var_name))]);
    end
    % 显示新变量的值
end

% XTest = [ones(1,6)*u0_0, ones(1,6)*u0_1, ones(1,6)*u0_2, ones(1,6)*u0_3];
T = 30.0;
T2 = round(T);
XTest = [];
% for i = 1:num
for i = 1:num
    XTest_cow = [];
    for j = 1:T2/6
        XTest_cow = [XTest_cow, ones(1,6)];
    end
    XTest = [XTest; XTest_cow];
end

u = [1 2 3;4 5 6];
u(1,2);

params = cell(2,4);
for i = 1:2
    for j = 1:4
        paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
        params{i,j} = paramName;
    end            % params{j} = paramName;
                    % p0{j} = 0;
end

strcat(params{i,j}) = 4;

inputnum = 2;
Totaltime = 30.0;

XTest = [];
for i = 1:inputnum
    XTest_row = [];
    for j = 1:round(Totaltime/6)
        XTest_row = [XTest_row, ones(1,6)*(i*j)];
    end
    XTest = [XTest; XTest_row];
 end
