#!/bin/bash



echo "gen start."
# python model_gen.py Conf/s12.conf gen
echo "gen end."

# train1, train2, train3 at same time
echo "train start."
# python model_gen.py Conf/s12.conf train Conf/m4.conf &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf train Conf/m2.conf &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf train Conf/m3.conf &
echo "train all end."

# wait for all
wait

# breach1, breach2, breach3 same time
echo "breach start."
# python model_gen.py Conf/s12.conf breach m4 &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf breach m2 &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf breach m3 &

wait

echo "All tasks completed."
# /Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -r "sendEmail('server3 over'); quit"

git status

git branch