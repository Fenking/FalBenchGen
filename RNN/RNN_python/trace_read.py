import numpy as np

def trace_read(in_tr, out_tr, m_v):

	input_traces = []
	output_traces = []
	print(in_tr)
	print(out_tr)

	for i in range(1, m_v):
		in_tr_branch = in_tr + '_' + str(i)
		with open(in_tr_branch, 'r') as fin:
			in_lines = fin.readlines()
			for in_line in in_lines:
				intr_str = in_line.strip()
				intr_str_sub = intr_str[1:-1]
				intr_str_sub_list = intr_str_sub.strip().split(',')
				intr_entry  = []
				for v_point in intr_str_sub_list:
					v_point_val =  v_point[1:-1]
					v_point_val_list  = v_point_val.strip().split(' ')
					v = list(map(float, v_point_val_list))
					intr_entry.append(v)
				input_traces.append(intr_entry)
				# if i == 1:
				# 	print(intr_entry)
		
	for j in range(1, m_v):
		out_tr_branch = out_tr + '_' + str(j)
		with open(out_tr_branch, 'r') as fout:
			out_lines = fout.readlines()
			for out_line in out_lines:
				outtr_str = out_line.strip()
				outtr_str_sub = outtr_str[1:-1]
				outtr_str_sub_list =  outtr_str_sub.strip().split(',')
				outtr_entry = []
				for v_point in outtr_str_sub_list:
					v_point_val = v_point[1:-1]
					v_point_val_list = v_point_val.strip().split(' ')
					v = list(map(float, v_point_val_list))
					outtr_entry.append(v)
				output_traces.append(outtr_entry)
				# if i == 1:
					# print(outtr_entry)
	
	np_in_tr = np.array(input_traces)
#	np_input_traces = np_in_tr.reshape(np_in_tr.shape + (1,))
	np_out_tr = np.array(output_traces)
#	np_output_traces = np_out_tr.reshape(np_out_tr.shape + (1,))
			
	print(np_in_tr.shape)	
	print(np_out_tr.shape)
	return np_in_tr, np_out_tr
