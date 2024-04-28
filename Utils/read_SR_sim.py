import os
import csv
import pandas as pd

# 设置文件夹路径
Gpath = '/Users/yipeiyan/Desktop/aws_yipei/breachDate_skt_delta=15-20_k'
# Gpath = '/Users/yipeiyan/Desktop/FalBench/Model/breachDate'

# 获取文件夹列表
folders = [f.name for f in os.scandir(Gpath) if f.is_dir()]
# folders = [f.name for f in os.scandir(Gpath) if f.is_dir() and '15' not in f.name]
folders.sort()

# 初始化数据列表
all_data = []

# 遍历每个文件夹
for i in range(len(folders)):
    folder_name = folders[i]
    folder_path = os.path.join(Gpath, folder_name)
    folder_marker = [folder_name, '', '', '']
    # all_data.append(folder_marker) ##1

    # 获取当前文件夹下的所有文件
    file_list = [f.path for f in os.scandir(folder_path) if f.is_file() and f.name.endswith('.txt')]
    # print(file_list) ##1

    # 保存三个文件名
    file_names = [os.path.basename(file_path) for file_path in file_list[:3]]
    file_names.sort()
    for file_name in file_names:
        # print(file_name) ##1
        # all_data.append([file_name]) ##1

        file_path = os.path.join(folder_path, file_name)
        with open(file_path, 'r') as file:
            file_data = file.readlines()
        
        row_data = []
        for k, line in enumerate(file_data):
            if 'breach by' in line:
                # row_data = [line.strip(), file_data[k+1].strip(), file_data[k+2].strip(), file_data[k+3].strip()]
                line = line.replace('breach by ', '')
                value1 = file_data[k+1].strip().replace('SR = ', '')
                value2 = file_data[k+2].strip().replace('avetime = ', '')
                value3 = file_data[k+3].strip().replace('#sim = ', '')
                # row_data = [line.strip(), value1, value2, value3] ##1
                row_data.append(value3) ##2
                # all_data.append(row_data) ##1
                # print(row_data)  # 打印保存的 row_data ##1
                k += 3
        # all_data.append(row_data)
        # print(row_data)
        # all_data.append('') ##1
        # all_data.append('') ##1

    # 输出文件名
    # print(f'文件夹 {folder_name} 下的文件名:')
    # print(file_names)
    if (i+1) % 5 == 0: ##2
        all_data.append(folder_marker[:4])
# 写入CSV文件
  

with open('output/output.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(all_data)

# 读取CSV并保存为Excel
df = pd.read_csv('output/output.csv', header=None)
# df.to_excel('output/output.xlsx', index=False, header=False)