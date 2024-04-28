import tensorflow as tf
import numpy as np
# from tensorflow.keras import Sequential
# from tensorflow.keras.layers import SimpleRNN
# from tensorflow.keras.layers import LSTM
# from tensorflow.keras.layers import Dense
# from tensorflow.keras.optimizers import SGD
# from tensorflow.keras.losses import mean_squared_error
# from tensorflow.keras.callbacks import ModelCheckpoint
# from tensorflow.keras.callbacks import EarlyStopping
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

def retrain(inputfile, outputfile, max_visits, bsize, epo, model_path, model_name, in_num, out_num):
	model = tf.keras.models.load_model(model_path + model_name)
	
	xx,yy = trace_read(inputfile, outputfile, max_visits)

	checkpointer  = ModelCheckpoint(filepath = model_path + model_name + '_weights.hdf5', monitor = 'loss', mode = 'min', verbose = 1, save_best_only = True)

	#earlystop = EarlyStopping(monitor = 'loss', mode = 'min', verbose = 1, min_delta = 0.5, patience = 5)

	#model.fit(xx, yy, batch_size = bsize, epochs = epo, callbacks = [checkpointer, earlystop])
	model.fit(xx, yy, batch_size = bsize, epochs = epo, callbacks = [checkpointer])

	model.save(model_path + model_name)
