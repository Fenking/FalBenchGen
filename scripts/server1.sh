#!/bin/bash


# gen
echo "gen start."
# python model_gen.py Conf/s1.conf gen
echo "gen end."

echo "train start."
# python model_gen.py Conf/s1.conf train Conf/m1.conf &
# python model_gen.py Conf/s1.conf train Conf/m2.conf &
# python model_gen.py Conf/s1.conf train Conf/m3.conf &
# python model_gen.py Conf/s1.conf train Conf/m4.conf &
# python model_gen.py Conf/s1.conf train Conf/m5.conf &
# wait
# python model_gen.py Conf/s1.conf train Conf/m6.conf &
# python model_gen.py Conf/s1.conf train Conf/m7.conf &
# python model_gen.py Conf/s1.conf train Conf/m8.conf &
# python model_gen.py Conf/s1.conf train Conf/m9.conf &
# python model_gen.py Conf/s1.conf train Conf/m10.conf &
# wait
# python model_gen.py Conf/s1.conf train Conf/m11.conf &
# python model_gen.py Conf/s1.conf train Conf/m12.conf &
# python model_gen.py Conf/s1.conf train Conf/m13.conf &
# python model_gen.py Conf/s1.conf train Conf/m14.conf &
# python model_gen.py Conf/s1.conf train Conf/m15.conf &


# wait
echo "train all end."


echo "breach start."
python model_gen.py Conf/s1.conf breach m1 &
python model_gen.py Conf/s1.conf breach m2 &
python model_gen.py Conf/s1.conf breach m3 &
python model_gen.py Conf/s1.conf breach m4 &
python model_gen.py Conf/s1.conf breach m5 &
wait
python model_gen.py Conf/s1.conf breach m6 &
python model_gen.py Conf/s1.conf breach m7 &
python model_gen.py Conf/s1.conf breach m8 &
python model_gen.py Conf/s1.conf breach m9 &
python model_gen.py Conf/s1.conf breach m10 &
wait
python model_gen.py Conf/s1.conf breach m11 &
python model_gen.py Conf/s1.conf breach m12 &
python model_gen.py Conf/s1.conf breach m13 &
python model_gen.py Conf/s1.conf breach m14 &
python model_gen.py Conf/s1.conf breach m15 &

wait

echo "All tasks completed."
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -r "sendEmail('server3 over'); quit"
