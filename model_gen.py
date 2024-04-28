import sys
import os
import matlab.engine
import time



phi_id = ''
phi_str = ''
phi_gen = ''
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
rec_lim = 1300
difficulty = 0.0

rnn_type = 'LSTM' ## ''
num_nn = []
optimization = ''
batch_size = 0
epochs = 0
num_model = 0

addpath = []
train_num = 1


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
		if status == 0:
			arg = argu[0]
			status = 1
		else:
			if arg == 'spec':
				phi_id = argu[0]
				phi_str = argu[1]
				phi_gen = argu[1]
			elif arg == 'spec_gen':
				phi_gen = argu[1]
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
			# elif arg == 'rec_lim': 
				# rec_lim = int(argu[0])
			elif arg == 'difficulty':
				difficulty = float(argu[0])
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
			bm.write('#!/bin/sh\n')
			bm.write('/home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash <<EOF\n')# 2023a successful easily.
			bm.write('clear;\n')
			for ap in addpath:
				bm.write('addpath(genpath(\'' + ap + '\'));\n')
			bm.write('addpath(genpath(\'' + home + '\'));\n')
			bm.write(phi_id + ' = STL_Formula(\'phi\',\'' + phi_gen + '\');\n')
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
			bm.write('set(0,\'RecursionLimit\',' + str(rec_lim) + ');\n')
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




elif sys.argv[2] == 'train':
	nn_id = ''
	# read layers and options about train model
	with open(sys.argv[3], 'r') as conf:
		for line in conf.readlines():
			argu = line.strip().split(';')
			if status == 0:
				arg = argu[0]
				status = 1
			else:
				if arg == 'nn_id':
					nn_id = argu[0]
				elif arg == 'rnn_type':
					rnn_type = argu[0]
				# elif arg == 'num_model':
				# 	num_model = int(argu[0])
				# 	nn_cnt = num_model
				elif arg == 'num_nn':
					# nn_cnt = nn_cnt - 1
					num_nn.append(int(argu[0]))
					# if nn_cnt != 0:
					# continue
				elif arg == 'optimization':
					optimization = argu[0]
				elif arg == 'batch_size':
					batch_size = int(argu[0])
				elif arg == 'epochs':
					epochs = int(argu[0])
				elif arg == 'train_num':
					train_num = int(argu[0])
				else:
					continue
				status = 0

	delta = str(sys.argv[4])
	#generate matlab main function
	for i in range(1):
		netname_suf = phi_id + '_' + nn_id + '_' + str(input_num) + '_' + str(controlpt) + '_' + str(switchpt) + '_' + str(num_var)+ '_' + str(difficulty) + '_' + rnn_type
		script_name = home + '/Data/mat/train/' + 'train_' + netname_suf
		model_dirpath = home + '/Model/Model_matlab/' + netname_suf
		# os.system('chmod 777 ' + home + '/Data/mat/breach/')
		# os.system('chmod 777 ' + script_name)
		with open(script_name, 'w') as bm:
			bm.write('#!/bin/sh\n')
			bm.write('/home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash <<EOF\n')
			bm.write('clear;\n')# 8 vars
			# bm.write("cd \'/Users/yipeiyan/Desktop/FalBench/RNN/RNN_matlab\';\n")
			bm.write("cd " + '\'' + home + "/RNN/RNN_matlab\';\n")
			bm.write('home = ' + '\'' + str(home) + '\'' + ';\n')
			bm.write('phi_id = ' + '\'' + str(phi_id) + '\'' + ';\n')
			bm.write('nn_id = ' + '\'' + str(nn_id) + '\'' + ';\n')
			bm.write('maxEpochs = ' + str(epochs) + ';\n')
			bm.write('miniBatchSize = ' + str(batch_size) + ';\n')
			bm.write('optimizer = ' + '\'' + str(optimization) + '\'' + ';\n')
			bm.write('numHiddenUnits = ' + str(num_nn[0]) + ';\n')
			bm.write('NetName = ' + '\'' + str(netname_suf) + '\'' + ';\n')
			bm.write('trainset = ' + '\'' + str(script_suf) + '\'' + ';\n')
			bm.write('inputnum = ' + str(input_num) + ';\n')
			bm.write('outputnum = ' + str(output_num) + ';\n')
			bm.write('train_num = ' + str(train_num) + ';\n')
			bm.write('delta = ' + str(delta) + ';\n')
			if train_num != 1:
				os.system('mkdir ' + model_dirpath)
			#dirpath = home + '/Data/trainset/' + script_suf
			# os.system('mkdir ' + dirpath)
			bm.write('trainNN_LSTM\n')
			bm.write('EOF\n')
		os.system('chmod 744 ' + script_name)
	os.system(script_name)
	print('data gen time = ' + str(time.time()-start_time))



elif sys.argv[2] == 'breach':

	nn_id = str(sys.argv[3])
	delta = str(sys.argv[4])
	#generate matlab main function
	for i in range(1):
		netname_suf = phi_id + '_' + nn_id + '_' + str(input_num) + '_' + str(controlpt) + '_' + str(switchpt) + '_' + str(num_var)+ '_' + str(difficulty) + '_' + rnn_type
		#script_suf = phi_id + '_' + str(input_num) + '_' + str(controlpt) + '_' + str(switchpt) + '_' + str(num_var)+ '_' + str(difficulty) + '_' + rnn_type + '_' + str(i)
		script_name = home + '/Data/mat/breach/' + 'breach_' + netname_suf
		model_dirpath = home + '/Model/Model_matlab/' + netname_suf
		breach_dirpath = home + '/Model/breachDate/' + 'Data_' + netname_suf
		train_num = sum([len(files) for _, _, files in os.walk(model_dirpath)])

		# os.system('chmod 777 ' + home + '/Data/mat/breach/')
		# os.system('chmod 777 ' + script_name)
		with open(script_name, 'w') as bm:
			bm.write('#!/bin/sh\n')
			bm.write('/home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash <<EOF\n')
			bm.write('clear;\n')# 6 vars
			for ap in addpath:
				bm.write('addpath(genpath(\'' + ap + '\'));\n')
			bm.write("cd " + '\'' + home + "/benchmark\';\n")
			bm.write('home = ' + '\'' + str(home) + '\'' + ';\n')
			bm.write('NetName = ' + '\'' + str(netname_suf) + '\'' + ';\n')
			bm.write('inputnum = ' + str(input_num) + ';\n')
			bm.write('outputnum = ' + str(output_num) + ';\n')
			bm.write('spec = ' + '\'' + str(phi_str) + '\'' + ';\n')
			bm.write('Totaltime = ' + str(total_time - 1) + ';\n')
			inputrange = ';'.join(map(str, input_range))
			bm.write('inputrange = ' + '[' + str(inputrange) + ']' + ';\n')
			bm.write('train_num = ' + str(train_num) + ';\n')
			bm.write('phi_id = ' + '\'' + str(phi_id) + '\'' + ';\n')
			bm.write('nn_id = ' + '\'' + str(nn_id) + '\'' + ';\n')
			if train_num != 0:
				os.system('mkdir ' + breach_dirpath)
			#dirpath = home + '/Data/trainset/' + script_suf
			# os.system('mkdir ' + dirpath)
			bm.write('breach_traces\n')
			bm.write('EOF\n')
		os.system('chmod 744 ' + script_name)
	os.system(script_name)
	print('data gen time = ' + str(time.time()-start_time))