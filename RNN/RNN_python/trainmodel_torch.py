import torch  
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import TensorDataset, DataLoader

from RNN.RNN_python.trace_read import trace_read

class RNNModel(nn.Module):
    def __init__(self, rnn_type, num_nn, in_num, out_num):
        super(RNNModel, self).__init__()
        if rnn_type == 'LSTM':
            self.rnn = nn.LSTM(in_num, num_nn, batch_first=True)
        else:
            self.rnn = nn.RNN(in_num, num_nn, batch_first=True)

        self.fc = nn.Linear(num_nn, out_num)
        
    def forward(self, x):
        self.rnn.flatten_parameters() 
        out, _ = self.rnn(x)   
        out = self.fc(out[:, -1, :]) 
        return out

def train_model(inputfile, outputfile, max_visits, optimization, rnn_type, num_nn, bsize, epo, model_path, model_name, in_num, out_num):
    x, y = trace_read(inputfile, outputfile, max_visits)

    x_tensor = torch.from_numpy(x).float()
    y_tensor = torch.from_numpy(y).float()

    dataset = TensorDataset(x_tensor, y_tensor)
    dataloader = DataLoader(dataset, batch_size=bsize, shuffle=True)

    model = RNNModel(rnn_type, num_nn, in_num, out_num)

    optimizer = optim.SGD(model.parameters(), lr=optimization)
    criterion = nn.MSELoss()

    for epoch in range(epo):
        for inputs, targets in dataloader:
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()

    torch.save(model.state_dict(), model_path + model_name + '_weights.pth')
