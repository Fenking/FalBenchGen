import sys
import os
from RNN.RNN_python.trainmodel import *
from RNN.RNN_python.retrain import *
import matlab.engine
import time

from RNN.RNN_python.trace_read import *


phi_id = ''
phi_str = ''
input_num = 0
input_range = []
controlpt = 0
output_num = 0
output_range = []
switchpt = 0
total_time = 0.0
step_size = 0.0
max_delta = []
num_var = 0
difficulty = 0.0
rnn_type = ''
num_nn = []
optimization = ''
batch_size = 0
epochs = 0
num_model = 0
addpath = []


home = os.getcwd()
m_file = ''
script_name = ''
dirpath = ''

def valid(eng, m_file, phi_str, mp, wp, ap, T):
	eng.addpath(home + '/Test/')
	v = eng.validate(m_file, phi_str, mp, wp, ap, T)
	return v


#read configuration
status = 0
arg = ''

nn_cnt = 0
with open(sys.argv[1], 'r') as conf:
	for line in conf.readlines():
		argu = line.strip().split(';')
		if status == 0:#跨行读取并保存arg名
			arg = argu[0]
			status = 1
		else:
			if arg == 'spec':#当读取到对应arg名的下一行对应数据时
				phi_id = argu[0]
				phi_str = argu[1]
			elif arg == 'inputnum':
				input_num = int(argu[0])
			elif arg == 'inputrange':
				for a in argu:
					a_item = a.split()
					input_range.append([float(a_item[0]), float(a_item[1])])
			elif arg == 'controlpt':
				controlpt = int(argu[0])
			elif arg == 'outputnum':
				output_num = int(argu[0])
			elif arg == 'outputrange':
				for a in argu:
					a_item = a.split()
					output_range.append([float(a_item[0]), float(a_item[1])])
			elif arg == 'switchpt':
				switchpt = int(argu[0])
			elif arg == 'total_time':
				total_time = float(argu[0])
			elif arg == 'step_size':
				step_size = float(argu[0])
			elif arg == 'max_delta':
				for a in argu:
					max_delta.append(float(a))
			elif arg == 'num_var':
				num_var = int(argu[0])
			elif arg == 'difficulty':
				difficulty = float(argu[0])
			elif arg == 'rnn_type':
				rnn_type = argu[0]
			elif arg == 'num_model':
				num_model = int(argu[0])
				nn_cnt = num_model
			elif arg == 'num_nn':
				nn_cnt = nn_cnt - 1
				num_nn.append(int(argu[0]))
				if nn_cnt != 0:
					continue
			elif arg == 'optimization':
				optimization = argu[0]
			elif arg == 'batch_size':
				batch_size = int(argu[0])
			elif arg == 'epochs':
				epochs = int(argu[0])
		#	elif arg == 'num_model':
		#		num_model = int(argu[0])
			elif arg == 'addpath':
				for a in argu:
					addpath.append(a)
			else:
				continue
			status = 0

i = 0
script_suf = phi_id + '_' + str(input_num) + '_' + str(controlpt) + '_' + str(switchpt) + '_' + str(num_var)+ '_' + str(difficulty) + '_' + rnn_type
dirpath = home + '/Data/trainset/' + script_suf

m_file = home + '/STL_TO_SMT/Faltr/' + script_suf + '_faltr.mat'

start_time = time.time()
if sys.argv[2] == 'gen':
	#generate matlab main function
	for i in range(1):
		#script_suf = phi_id + '_' + str(input_num) + '_' + str(controlpt) + '_' + str(switchpt) + '_' + str(num_var)+ '_' + str(difficulty) + '_' + rnn_type + '_' + str(i)
		script_name = home + '/Data/mat/main/' + 'main_' + script_suf
		with open(script_name, 'w') as bm:
			bm.write('#!/bin/sh\n')#设置matlab环境
			bm.write('/Applications/MATLAB_R2023b.app/bin/matlab -nodesktop -nosplash <<EOF\n')
			bm.write('clear;\n')#以下为breach和matlab代码,文件在Data/mat中
			for ap in addpath:
				bm.write('addpath(genpath(\'' + ap + '\'));\n')
			bm.write(phi_id + ' = STL_Formula(\'phi\',\'' + phi_str + '\');\n')
			bm.write('addpath([\'STL_TO_SMT\'],[\'STL_TO_SMT\' filesep \'infix2prefix\']);\n\n')
			bm.write('switchpt = ' + str(switchpt) + ';\n')
			bm.write('T = ' + str(total_time) + ';\n')
			bm.write('input_num = ' +  str(input_num) + ';\n')
			bm.write('input_range = [')
			ir0 = input_range[0]
			bm.write(str(ir0[0]) + ' ' + str(ir0[1]))
			for ir in input_range[1:]:
				bm.write(';' + str(ir[0]) + ' ' + str(ir[1]))
			bm.write('];\n')

			bm.write('output_range = [')
			or0 = output_range[0]
			bm.write(str(or0[0]) + ' ' + str(or0[1]))
			for orr in output_range[1:]:
				bm.write(';' + str(orr[0]) + ' ' + str(orr[1]))
			bm.write('];\n')

			bm.write('controlpt = ' + str(controlpt) + ';\n')
			bm.write('num_var = ' + str(num_var) + ';\n')
			#dirpath = home + '/Data/trainset/' + script_suf
			os.system('mkdir ' + dirpath)
			bm.write('inputf = \'' + script_suf + '/input_traces\';\n')
			bm.write('outputf = \'' + script_suf + '/output_traces\';\n')
			bm.write('step_size = ' + str(step_size) + ';\n')

			bm.write('delta_range = [0 ' + str(max_delta[0]))
			for md in max_delta[1:]:
				bm.write(';0 ' + str(md))
			bm.write('];\n')
		
			bm.write('h = ' + str(difficulty) + ';\n\n')
			bm.write('cd \'STL_TO_SMT/\'\n')
			bm.write('gt = TraceGenerator(inputf, outputf, num_var, controlpt, T, switchpt, step_size, input_num, input_range, output_range, h, ' + phi_id + ', delta_range);\n')
			bm.write('gt.gen();\n')
			bm.write('fal_tr = gt.fal_tr;\n')
		
		#	m_file = home + '/STL_TO_SMT/Faltr/' + script_suf + '_faltr.mat'

			bm.write('save(\''  + m_file + '\', \'fal_tr\');\n')
			bm.write('quit\n')
			bm.write('EOF\n')
		os.system('chmod 744 ' + script_name)


#run matlab and train
#files = os.listdir('Data/mat/')
#for script in files:
#	if not os.path.isdir(script):

#	start_time = time.time()
	os.system(script_name)
	print('data gen time = ' + str(time.time()-start_time))


elif sys.argv[2] == 'train_python':
	for nn in num_nn:
		inputf = dirpath + '/input_traces'
		outputf = dirpath + '/output_traces'
		trainmodel(inputf, outputf, num_var, optimization, rnn_type, nn, batch_size, epochs, home + '/Model/', 'model_' + script_suf + '_' + str(nn),  input_num, output_num)

		print('(from start) first train time = ' + str(time.time()- start_time))

elif sys.argv[2] == 'continue':
#sysarg3: which model #i to continue
	inputf = dirpath + '/input_traces'
	outputf = dirpath + '/output_traces'
	retrain(inputf, outputf, num_var, batch_size, epochs, home + '/Model/', 'model_' + script_suf + '_' + sys.argv[3], input_num, output_num)
	print('(from start) continue time = ' + str(time.time() - start_time))


elif sys.argv[2] == 'retrain':
#model validation and retrain
	eng = matlab.engine.start_matlab()
	brpath = addpath[0]
	eng.addpath(eng.genpath(brpath))
	k = 1
	while not valid(eng, m_file, phi_str, home + '/Model/model_' + script_suf, home + '/Model/model_' + script_suf + '_weights.hdf5', brpath, total_time):
		#add_inf = dirpath + '/add_input_' + str(k)
		#add_outf = dirpath + '/add_output_'  + str(k)
		eng.addpath(home + '/STL_TO_SMT/')
		eng.data_augment(m_file, inputf,  outputf, input_range, nargout = 0)
		trainmodel(inputf, outputf, optimization, rnn_type, num_nn, batch_size, epochs, home + '/Model/', 'model_' + script_suf,  input_num, output_num)
		#eng.data_augment(m_file, add_inf,  add_outf, input_range, nargout = 0)
		#retrain(add_inf, add_outf, 100, 200, home + '/Model/', 'model_' + script_suf, input_num, output_num)
		k = k  + 1
	eng.quit()
	print('(from start) until retrain finish  = ' + str(time.time()- start_time))


elif sys.argv[2] == 'test':
	for nn in num_nn:
		inputf = home + '/Data/test/' + '/input_traces'
		outputf = home + '/Data/test/' + '/output_traces'
		num_var = 2
		nn = 10
		batch_size = 16
		epochs = 10
		trainmodel(inputf, outputf, num_var, optimization, rnn_type, nn, batch_size, epochs, home + '/Data/test/', 'model_test_' + script_suf + '_' + str(nn),  input_num, output_num)

		print('(from start) first test time = ' + str(time.time()- start_time))

elif sys.argv[2] == 'test_continue':
#sysarg3: which model #i to continue
	inputf = home + '/Data/test/' + '/input_traces'
	outputf = home + '/Data/test/' + '/output_traces'
	num_var = 3
	# 这里再次读取num_var，如果是直接使用的话是否有变化？
	nn = 10
	batch_size = 16
	epochs = 10
	retrain(inputf, outputf, num_var, batch_size, epochs, home + '/Data/test/', 'model_test_' + script_suf + '_' + sys.argv[3], input_num, output_num)
	print('(from start) continue time = ' + str(time.time() - start_time))


elif sys.argv[2] == 'test_retrain':#x
#model validation and retrain
	inputf = home + '/Data/test/' + '/input_traces'
	outputf = home + '/Data/test/' + '/output_traces'
	eng = matlab.engine.start_matlab()
	brpath = addpath[0]
	eng.addpath(eng.genpath(brpath))
	k = 1
	while not valid(eng, m_file, phi_str, home + '/Data/test/model_test_' + script_suf, home + '/Data/test/model_test_' + script_suf + '_weights.hdf5', brpath, total_time):
		# add_inf = dirpath + '/add_input_' + str(k)
		# add_outf = dirpath + '/add_output_'  + str(k)
		eng.addpath(home + '/STL_TO_SMT/')
		eng.data_augment(m_file, inputf,  outputf, input_range, nargout = 0)
		trainmodel(inputf, outputf, optimization, rnn_type, num_nn, batch_size, epochs, home + '/Data/test/', 'model_test_' + script_suf,  input_num, output_num)
		#eng.data_augment(m_file, add_inf,  add_outf, input_range, nargout = 0)
		#retrain(add_inf, add_outf, 100, 200, home + '/Model/', 'model_' + script_suf, input_num, output_num)
		k = k  + 1
	eng.quit()
	print('(from start) until retrain finish  = ' + str(time.time()- start_time))


elif sys.argv[2] == 'trace_read':
	inputf = home + '/Data/test/' + '/input_traces'
	outputf = home + '/Data/test/' + '/output_traces'
	num_var = 2
	x, y = trace_read(inputf, outputf, num_var)
	# print(x[0])
	'''
[[6.5112]
 [6.5112]
 [6.5112]
 [6.5112]
 [6.5112]
 [6.5112]
 [8.7799]
 [8.7799]
 [8.7799]
 [8.7799]
 [8.7799]
 [8.7799]
 [2.2249]
 [2.2249]
 [2.2249]
 [2.2249]
 [2.2249]
 [2.2249]
 [2.8804]
 [2.8804]
 [2.8804]
 [2.8804]
 [2.8804]
 [2.8804]]
	'''
	xx = x.tolist()
	yy = y.tolist()
	with open('input_print.txt','w',encoding='utf-8') as f1:
		for line in xx:
			line = ' '.join(map(str, line))
			f1.write(line)
			f1.write('\n')
	with open('output_print.txt','w',encoding='utf-8') as f2:
		for line in yy:
			line = ' '.join(map(str, line))
			f2.write(line)
			f2.write('\n')

elif sys.argv[2] == 'train':
	#generate matlab main function
	for i in range(1):
		#script_suf = phi_id + '_' + str(input_num) + '_' + str(controlpt) + '_' + str(switchpt) + '_' + str(num_var)+ '_' + str(difficulty) + '_' + rnn_type + '_' + str(i)
		script_name = home + '/Data/mat/train/' + 'train_' + script_suf
		with open(script_name, 'w') as bm:
			bm.write('#!/bin/sh\n')#设置matlab环境
			bm.write('/Applications/MATLAB_R2023b.app/bin/matlab -nodesktop -nosplash <<EOF\n')
			bm.write('clear;\n')#以下为breach和matlab代码,文件在Data/mat中
			bm.write("\'cd \'/Users/yipeiyan/Desktop/FalBench/RNN/RNN_matlab\';\n")
			bm.write('addpath(genpath(\'' + ap + '\'));\n')
			bm.write(phi_id + ' = STL_Formula(\'phi\',\'' + phi_str + '\');\n')
			bm.write('addpath([\'STL_TO_SMT\'],[\'STL_TO_SMT\' filesep \'infix2prefix\']);\n\n')
			bm.write('switchpt = ' + str(switchpt) + ';\n')
			bm.write('T = ' + str(total_time) + ';\n')
			bm.write('input_num = ' +  str(input_num) + ';\n')
			bm.write('input_range = [')
			ir0 = input_range[0]
			bm.write(str(ir0[0]) + ' ' + str(ir0[1]))
			for ir in input_range[1:]:
				bm.write(';' + str(ir[0]) + ' ' + str(ir[1]))
			bm.write('];\n')

			bm.write('output_range = [')
			or0 = output_range[0]
			bm.write(str(or0[0]) + ' ' + str(or0[1]))
			for orr in output_range[1:]:
				bm.write(';' + str(orr[0]) + ' ' + str(orr[1]))
			bm.write('];\n')

			bm.write('controlpt = ' + str(controlpt) + ';\n')
			bm.write('num_var = ' + str(num_var) + ';\n')
			#dirpath = home + '/Data/trainset/' + script_suf
			os.system('mkdir ' + dirpath)
			bm.write('inputf = \'' + script_suf + '/input_traces\';\n')
			bm.write('outputf = \'' + script_suf + '/output_traces\';\n')
			bm.write('step_size = ' + str(step_size) + ';\n')

			bm.write('delta_range = [0 ' + str(max_delta[0]))
			for md in max_delta[1:]:
				bm.write(';0 ' + str(md))
			bm.write('];\n')
		
			bm.write('h = ' + str(difficulty) + ';\n\n')
			bm.write('cd \'STL_TO_SMT/\'\n')
			bm.write('gt = TraceGenerator(inputf, outputf, num_var, controlpt, T, switchpt, step_size, input_num, input_range, output_range, h, ' + phi_id + ', delta_range);\n')
			bm.write('gt.gen();\n')
			bm.write('fal_tr = gt.fal_tr;\n')
		
		#	m_file = home + '/STL_TO_SMT/Faltr/' + script_suf + '_faltr.mat'

			bm.write('save(\''  + m_file + '\', \'fal_tr\');\n')
			bm.write('quit\n')
			bm.write('EOF\n')
		os.system('chmod 744 ' + script_name)