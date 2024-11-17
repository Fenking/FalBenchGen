import os
import csv
import pandas as pd
import re

# 设置文件夹路径
# Gpath = '/Users/yipeiyan/Desktop/aws_yipei/breachData_cc35c t2'
# Gpath = '/Users/yipeiyan/Desktop/FalBench/Model/breachDate'
# Gpath = '/Users/yipeiyan/Desktop/FalBench/ARCHtest/breachData/'
Gpath = '/Users/yipeiyan/Desktop/aws_yipei/breachDate_delta=10/breachDate_delta=10_200'

# 获取文件夹列表
folders = [f.name for f in os.scandir(Gpath) if f.is_dir()]
# folders = [f.name for f in os.scandir(Gpath) if f.is_dir() and '15' not in f.name]
folders.sort()

# 初始化数据列表
all_data = []
all_data2 = []

# pattern = r"^cc3a\d$|^cc5a.*d10$"
pattern = r"^s1a\d$|^s1c\d$"

# 遍历每个文件夹
for i in range(len(folders)):
    folder_name = folders[i]
    folder_name2 = folder_name.split('_')[1]
    if re.search(pattern, folder_name2):
        continue
    folder_path = os.path.join(Gpath, folder_name)
    folder_marker = [folder_name2, '', '', '']
    if i % 5 == 0:
        all_data.append('')
        all_data.append('')
        all_data.append(folder_marker) ##1
        all_data2.append('') 
        all_data2.append('') 
        all_data2.append(folder_marker) ##1

    # 获取当前文件夹下的所有文件
    file_list = [f.path for f in os.scandir(folder_path) if f.is_file() and f.name.endswith('.txt')]
    print(file_list) ##1

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
        row_data2 = []
        for k, line in enumerate(file_data):
            if 'breach by' in line:
                # row_data = [line.strip(), file_data[k+1].strip(), file_data[k+2].strip(), file_data[k+3].strip()]
                line = line.replace('breach by ', '')
                value1 = file_data[k+1].strip().replace('SR = ', '')
                value2 = file_data[k+2].strip().replace('avetime = ', '')
                value3 = file_data[k+3].strip().replace('#sim = ', '')
                # row_data = [line.strip(), value1, value2, value3] ##1
                row_data.append(value1) ##2
                row_data2.append(value3) ##2

                # all_data.append(row_data) ##1
                # print(row_data)  # 打印保存的 row_data ##1
                k += 3
        all_data.append(row_data)
        all_data2.append(row_data2)
        # print(row_data)
        # all_data.append('') ##1
        # all_data.append('') ##1
        # all_data2.append('') 

    # 输出文件名
    # print(f'文件夹 {folder_name} 下的文件名:')
    # print(file_names)
    # if (i+1) % 5 == 0: ##2
        # all_data.append(folder_marker[:4])
# 写入CSV文件

p = 0
while p < len(all_data):
    k1 = []
    k2 = []
    k3 = []

    q = p + 3  # 初始化 q 为 p + 3
    while q < p + 18:
        k1.append(all_data[q])
        k2.append(all_data[q + 1])
        k3.append(all_data[q + 2])
        q += 3  # 每次跳过 3 行，即每次处理一组数据

    all_data[p + 3:p + 3 + 5] = k1
    all_data[p + 5 + 3:p + 5 + 3 + 5] = k2
    all_data[p + 10 + 3:p + 10 + 3 + 5] = k3
    p += 18


p = 0
while p < len(all_data2):
    k1 = []
    k2 = []
    k3 = []

    q = p + 3  # 初始化 q 为 p + 3
    while q < p + 18:
        k1.append(all_data2[q])
        k2.append(all_data2[q + 1])
        k3.append(all_data2[q + 2])
        q += 3  # 每次跳过 3 行，即每次处理一组数据

    all_data2[p + 3:p + 3 + 5] = k1
    all_data2[p + 5 + 3:p + 5 + 3 + 5] = k2
    all_data2[p + 10 + 3:p + 10 + 3 + 5] = k3
    p += 18
  

with open(Gpath+'/SR.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(all_data)

# 读取CSV并保存为Excel
df = pd.read_csv(Gpath+'/SR.csv', header=None)
# df.to_excel('output/output.xlsx', index=False, header=False)

with open(Gpath+'/sim.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(all_data2)

# 读取CSV并保存为Excel
df = pd.read_csv(Gpath+'/sim.csv', header=None)
# df.to_excel('output/output.xlsx', index=False, header=False)