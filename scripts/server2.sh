#!/bin/bash



echo "gen start."
# python model_gen.py Conf/s2.conf gen
echo "gen end."


echo "train start."
# python model_gen.py Conf/s2.conf train Conf/m1.conf &
# python model_gen.py Conf/s2.conf train Conf/m2.conf &
# python model_gen.py Conf/s2.conf train Conf/m4.conf &
# python model_gen.py Conf/s2.conf train Conf/m5.conf &


wait
echo "train all end."


echo "breach start."
python model_gen.py Conf/s2.conf breach m1
python model_gen.py Conf/s2.conf breach m2
python model_gen.py Conf/s2.conf breach m4
python model_gen.py Conf/s2.conf breach m5


echo "All tasks completed."
