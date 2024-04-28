import tensorflow as tf 
import numpy as np 
# from tensorflow.keras import Sequential 
# from tensorflow.keras.layers import SimpleRNN
# from tensorflow.keras.layers import LSTM
# from tensorflow.keras.layers import Dense
# from tensorflow.keras.optimizers import SGD
# from tensorflow.keras.losses import mean_squared_error
# from tensorflow.keras.callbacks import ModelCheckpoint
from tensorflow import keras
from keras import Sequential 
from keras.layers import SimpleRNN
from keras.layers import LSTM
from keras.layers import Dense
from keras.optimizers import SGD
from keras.losses import mean_squared_error
from keras.callbacks import ModelCheckpoint


import sys
from RNN.RNN_python.trace_read import trace_read

def trainmodel(inputfile, outputfile, max_visits, optimization, rnn_type, num_nn, bsize, epo, model_path, model_name, in_num, out_num):

	model = Sequential()
	
	if rnn_type == 'LSTM':
		model.add(LSTM(num_nn, input_shape = (None, in_num), return_sequences = True))
	else:
		model.add(SimpleRNN(num_nn, input_shape = (None, in_num), return_sequences = True))

	model.add(Dense(out_num))

	model.compile(optimizer=optimization, loss='mean_squared_error', metrics= ['mse'])

	checkpointer  = ModelCheckpoint(filepath = model_path + model_name + '_weights.hdf5', monitor = 'loss', mode = 'min', verbose = 1, save_best_only = True)

#x, y = trainset_gen('sat_traces', 'vio_traces', 0.3, 5, 30, 1, 1, [0, 10], 10000)
	x, y = trace_read(inputfile, outputfile, max_visits)

	model.fit(x, y, batch_size = bsize, epochs=epo, callbacks = [checkpointer])

#	model.layers[0].weights
# [<tf.Variable 'simple_rnn/kernel:0' shape=(1, 1) dtype=float32, numpy=array([[0.6021545]], dtype=float32)>,
#  <tf.Variable 'simple_rnn/recurrent_kernel:0' shape=(1, 1) dtype=float32, numpy=array([[1.0050855]], dtype=float32)>,
#  <tf.Variable 'simple_rnn/bias:0' shape=(1,) dtype=float32, numpy=array([0.20719269], dtype=float32)>]

	model.save(model_path + model_name)

#print(model.predict(np.ones((1, 31, 1)) * 0.5).flatten())
# array([ 0.5082699,  1.0191246,  1.5325773,  2.0486412,  2.5673294,
#         3.0886555,  3.6126328,  4.1392746,  4.6685944,  5.2006063,
#         5.7353234,  6.27276  ,  6.8129296,  7.3558464,  7.901524 ,
#         8.449977 ,  9.00122  ,  9.555265 , 10.112128 , 10.6718235,
#        11.2343645, 11.799767 , 12.368044 , 12.939212 , 13.513284 ,
#        14.090276 , 14.670201 , 15.253077 , 15.838916 , 16.427734 ],
#       dtype=float32)
