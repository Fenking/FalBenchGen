#!/bin/bash



echo "gen start."
/usr/bin/python3.8 model_gen.py Conf/s11.conf gen
echo "gen end."


echo "train start."
/usr/bin/python3.8 model_gen.py Conf/s11.conf train Conf/m4.conf &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf train Conf/m2.conf &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf train Conf/m3.conf &
echo "train all end."


wait


echo "breach start."
/usr/bin/python3.8 model_gen.py Conf/s11.conf breach m4 &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf breach m2 &
# /usr/bin/python3.8 model_gen.py Conf/s11.conf breach m3 &

wait

echo "All tasks completed."

/home/server/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('train over'); quit"
