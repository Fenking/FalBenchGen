#!/bin/bash



echo "gen1 start."
# python model_gen.py Conf/s1c1.conf gen
echo "gen1 end."

echo "gen2 start."
# python model_gen.py Conf/s1c2.conf gen
echo "gen2 end."

echo "gen3 start."
# python model_gen.py Conf/s1c3.conf gen
echo "gen3 end."

echo "gen4 start."
# python model_gen.py Conf/s1c4.conf gen
echo "gen4 end."

# /home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('gen c234 over'); quit"



# echo "train s1a1 start."
# python model_gen.py Conf/s1c1.conf train Conf/k1.conf &
# python model_gen.py Conf/s1c1.conf train Conf/k2.conf &
# python model_gen.py Conf/s1c1.conf train Conf/k3.conf &
# python model_gen.py Conf/s1c1.conf train Conf/k4.conf &

# wait
# echo "train all end."

# /home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('train c1 over'); quit"

# echo "train s1a1 start."
# python model_gen.py Conf/s1c2.conf train Conf/k1.conf &
# python model_gen.py Conf/s1c2.conf train Conf/k2.conf &
# python model_gen.py Conf/s1c2.conf train Conf/k3.conf &
# python model_gen.py Conf/s1c2.conf train Conf/k4.conf &

# wait
# echo "train all end."

# /home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('train c2 over'); quit"

# echo "train s1a1 start."
# python model_gen.py Conf/s1c3.conf train Conf/k1.conf &
# python model_gen.py Conf/s1c3.conf train Conf/k2.conf &
# python model_gen.py Conf/s1c3.conf train Conf/k3.conf &
# python model_gen.py Conf/s1c3.conf train Conf/k4.conf &

# wait
# echo "train all end."

# /home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('train c3 over'); quit"

# echo "train s1a1 start."
# python model_gen.py Conf/s1c4.conf train Conf/k1.conf &
# python model_gen.py Conf/s1c4.conf train Conf/k2.conf &
# python model_gen.py Conf/s1c4.conf train Conf/k3.conf &
# python model_gen.py Conf/s1c4.conf train Conf/k4.conf &

# wait
# echo "train all end."

# /home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('train c4 over'); quit"


echo "breach start."
# python model_gen.py Conf/s1c1.conf breach k1 &
# python model_gen.py Conf/s1c1.conf breach k2 &
# python model_gen.py Conf/s1c1.conf breach k3 &
# python model_gen.py Conf/s1c1.conf breach k4 &
# wait
python model_gen.py Conf/s1c2.conf breach k1 &
python model_gen.py Conf/s1c2.conf breach k2 &
python model_gen.py Conf/s1c2.conf breach k3 &
python model_gen.py Conf/s1c2.conf breach k4 &

wait


echo "breach start."
python model_gen.py Conf/s1c3.conf breach k1 &
python model_gen.py Conf/s1c3.conf breach k2 &
python model_gen.py Conf/s1c3.conf breach k3 &
python model_gen.py Conf/s1c3.conf breach k4 &
wait
python model_gen.py Conf/s1c4.conf breach k1 &
python model_gen.py Conf/s1c4.conf breach k2 &
python model_gen.py Conf/s1c4.conf breach k3 &
python model_gen.py Conf/s1c4.conf breach k4 &

wait

echo "All tasks completed."
# /home/ctr/MATLAB/R2021a/bin/matlab -nodesktop -nosplash -r "sendEmail('1c_new over'); quit"
