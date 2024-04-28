


% home = '/Users/yipeiyan/Desktop/aws_yipei/FalBench';


% FolderPath = '/Users/yipeiyan/Desktop/aws_yipei/FalBench/Model/breachDate/';
FolderPath = '/Users/yipeiyan/Desktop/aws_yipei/breachDate_delta=10';
filePattern = fullfile(FolderPath,['Data_s','*']);
files = dir(filePattern);
folders = files([files.isdir]);

% disp({folders.name});
allDataCell = cell(0, 4); % 初始大小为 0 行 4 列

% 遍历每个文件夹
% for i = 1:length(folders)
for i = 1:3
    folderName = folders(i).name;
    folderPath = fullfile(FolderPath, folderName);
    folderMarkerRow = {folderName, '', '', ''};
    allDataCell = [allDataCell; folderMarkerRow];
    
    % 获取当前文件夹下的所有文件
    fileList = dir(fullfile(folderPath, '*.txt'));
    dataCell = cell(0, 4);
    
    % 保存三个文件名
    fileNames = {};
    for j = 1:length(fileList) % 最多遍历三个文件
        if ~fileList(j).isdir % 确保不是文件夹
            fileNames{end+1} = fileList(j).name;
            disp(fileList(j));

            fileID = fopen(fileList(j).name, 'r'); % 打开文件
            % fileContent = fread(fileID, '*char')';
            fileData = textscan(fileID, '%s', 'Delimiter', '\n'); % 按行读取文件内容
            fileData = fileData{1};
            fclose(fileID);
            % fileData = strsplit(fileContent, '\n');
            for k = 1:length(fileData)
                line = fileData{k};
                % 检查是否包含 "breach by"
                if contains(line, 'breach by')
                    % disp(line);
                    % disp(fileData{k+1});
                    % disp(fileData{k+2});
                    % disp(fileData{k+3});
                    rowData = {line, fileData{k+1}, fileData{k+2}, fileData{k+3}};
                    dataCell = [dataCell; rowData]; % 添加到当前文件夹的单元数组中
                    % 跳过下面的三行
                    k = k + 3;
                end
            end
        end
    end
    allDataCell = [allDataCell; dataCell];
    
    % 输出文件名
    % disp(['文件夹 ', folderName, ' 下的文件名:']);
    % disp(fileNames);
end




% 创建表格
T = table(fileData{1}, fileData{2}, fileData{3}, 'VariableNames', {'Name', 'Value1', 'Value2'});

% 将表格写入新文件
writetable(T, 'output.xlsx'); % 输出为 Excel 文件
