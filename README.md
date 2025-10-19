# FalBenchGen

The code for [Automated Generation of Benchmarks for STL Specifications Falsification](https://ieeexplore.ieee.org/document/10922764).
Published in [IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems](https://ieeexplore.ieee.org/xpl/RecentIssue.jsp?punumber=43), 
DOI: 10.1109/TCAD.2025.3550410, in 2025/03/13.

## Install

- clone this repository,
    - use `git clone git@github.com:Fenking/FalBenchGen.git`
- Install [Breach](https://github.com/decyphir/breach).
    1. `git clone -b 1.8.0 git@github.com:decyphir/breach.git`
    2. start matlab, set up a C/C++ compiler using the command `mex -setup C++`. (Refer to [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html) for more details.)
    3. navigate to `breach/` in Matlab commandline, and run `InstallBreach`
- Check your Python as `python --version` or `python3 --version` to  switch the code you need use.
- [Install matlab python engine](https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html)
    1. [Check your Python and Matlab version](https://ww2.mathworks.cn/support/requirements/python-compatibility.html) so that to make sure the correct version you have.
    2. if not work, use `sudo /yourroute/python3 setup.py install` to install.
- Check if you have Java by `java -version`.If not, Install Java by `sudo apt install openjdk-11-jdk`
    1. Check Java by `javac -version`
    2. if you do not have Javac, use `sudo apt install openjdk-11-jdk-headless` to install it.
- Check if you have jflex by `jflex --version`.If not, Install jflex by `sudo apt install jflex`
    1. Check jflex by `jflex --version`
- Check if you bison Java by `bison -version`.If not, Install bison by `sudo apt install bison`
    1. Check bison by `bison --version`
- Before start the FalBenchGen, open `Conf/xx.conf` and `model_gen.py` to change the route breach and matlab

### Using

- Change the route of matlab at `model_gen.py` .
- Add new configuration file at `Conf/` to create new task.
    1. New task about create new traces like `Conf/template_trace.conf` or `Conf/s1.conf` and change the breach route at the last line.
    2. New task about create LSTM net and breach test like `Conf/template_LSTM_options.conf` or `Conf/k1.conf`.
- You can use `train` and `breach` module in this git.
- Use `python model_gen.py Conf/s1.conf train Conf/k1.conf X` to start task about create new LSTM net by using traeces of s1 and options of k1.
    1. the `X` is the delta of configuration and we can use delta = 2/5/10 for spec s1, s3 and s5.
    2. others, we can also use delta = 20 for spec s3 ,s3k and s3t.
- Use `python model_gen.py Conf/s1.conf breach k1` to start task about create new breach test by using the LSTM net from s1 and k1.
- Add new scripts file at `scripts/` to integrate the above 3 instructions like `scripts/template.sh` or `scripts/server1.sh` ,and then use `sh scripts/server1.sh` to execute them.
    1. You can also execute it by nohup as `nohup sh scripts/server1.sh > Log/server1.log 2>&1 &` and get the ID like `XXXX`.
    2. Also, you can use tmex to execute them.

### FAQ

- "z3 version `glibcxx_3.4.26` not found"
    1. make sure which `glibcxx_3.4.XX` you not have
    2. use `strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBC` to check there is enough `glibcxx_3.4.XX` to use.(please change the route about `libstdc++.so.6`)
    3. `rm -rf /matlabroot/sys/os/glnxa64/libstdc++.so.6`
    4. `ln -s /usr/lib32/libstdc++.so.6 /matlabroot/sys/os/glnxa64/libstdc++.so.6` to exchange out.
- “`saoptimset` cannot be recognized.”
    1. `nano breach/Core/Algos/@BreachProblem/BreachProblem.m` .
    2. Replace the function `solver_opt = setup_simulannealbnd(this)`
    3. Change all `saoptimset` to `optimset` (have 2).
- Modify the seed of CMA-ES algorithm.
    1. `vi /breach/Core/Algos/@BreachProblems/BreachProblems.m`
    2. Replace the line `solver_opt.Seed = 0` with `solver_opt.Seed = round (rem(now, 1)*1000000)` in the
    `setup_caes` function.
- The `sh scripts/serverXX.sh` file execution fails
    1. ensure you have the necessary permissions to run the program.
    2. you can change the code like make `python` to `/usr/bin/python3.8`(the route on your server/cumputer), you can refer to the `scripts/test1.sh`.
- Specifications we used:
    1. $\phi_1$ = s1 = `alw_[0,24](b[t] < 20)`
       - output range = [-50,50]
    2. $\phi_2$ = s3 = `alw_[0,18](b[t] > 90 or ev_[0,6](b[t] < 50))`
       - output range = [0,100]
    3. $\phi_3$ = s5 = `not (ev_[6,12](b[t] > 10)) or alw_[18,24](b[t] > -10)`
       - output range = [-50,50]
    4. $\phi_4$ = cc3 = `alw_[0,20](alw_[0,5](b1[t]<=20) or ev_[0,5](b2[t]>=40))`
       - output range = [-100,100;-100,100]
    5. $\phi_5$ = cc5 = `alw_[0,18](ev_[0,2](not(alw_[0,1](b1[t] >= 9)) or alw_[1,5](b2[t]>= 9)))`
       - output range = [-100,100;-100,100]
    6. $\phi_{2k}$ = s3k = `alw_[0,18](b[t] > 30 or ev_[0,6](b[t] < -10))`(not used in paper)
       - output range = [-50,50]
    7. $\phi_{2t}$ = s3t = `alw_[0,18](b[t] < 30 or ev_[0,6](b[t] < -10))`(not used in paper)
       - output range = [-50,50]

### Figures of Research Question

##### RQ1: Results across all the benchmarks, and for each specification

- Avg-SR
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_Avg_Boxplot_Budget_1000_Scattered.jpg" width="40%"/>
</center>

- Stdv-SR
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_Stdv_Boxplot_Budget_1000_Scattered.jpg" width="40%"/>
</center>

##### RQ1: Number of generated benchmarks per **RankNumber**

- <center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_Legend.jpg" width="80%"/>
</center>

- ALL
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_All_Budget_1000.jpg" width="40%"/>
</center>

- $\phi_1$
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_S1_Budget_1000.jpg" width="40%"/>
</center>

- $\phi_2$
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_S3_Budget_1000.jpg" width="40%"/>
</center>

- $\phi_3$
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_S5_Budget_1000.jpg" width="40%"/>
</center>

- $\phi_4$
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_CC3_Budget_1000.jpg" width="40%"/>
</center>

- $\phi_5$
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ1/RQ1_CC5_Budget_1000.jpg" width="40%"/>
</center>


##### RQ2: Results for different values of violation ratio $vr \in \\{0, 0.01, 0.05, 0.1\\}$

- Avg-SR
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ2/RQ2_Avg_Boxplot_Budget_1000_Scattered.jpg" width="40%"/>
</center>

- Stdv-SR
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ2/RQ2_Stdv_Boxplot_Budget_1000_Scattered.jpg" width="40%"/>
</center>


##### RQ4: Ranking positions of falsification approaches. 
Each stacked bar reports, for a given falsification approach (on the x-axis), the percentage of benchmarks (y-axis) in which the approach is in 1st, 2nd, 3rd, or 4th position (starting from the bottom), using different colors. The numbers inside the stacked bar represent the concrete numbers of benchmarks. The number at the top of the stacked bar represents the total number of benchmarks for that specification.

- 1000 simulations
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ4/RQ4_StackedBar_Budget_1000.jpg" width="40%"/>
</center>

- 800 simulations
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ4/RQ4_StackedBar_Budget_800.jpg" width="40%"/>
</center>

- 600 simulations
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ4/RQ4_StackedBar_Budget_600.jpg" width="40%"/>
</center>

- 400 simulations
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ4/RQ4_StackedBar_Budget_400.jpg" width="40%"/>
</center>

- 200 simulations
<center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ4/RQ4_StackedBar_Budget_200.jpg" width="40%"/>
</center>


##### RQ5: Distribution of ranking number **RankNumber** of the benchmarks of the ARCH competition

- <center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ5/RQ5_Legend.jpg" width="40%"/>
</center>

- <center class="half">
  <img src="https://github.com/Fenking/FalBenchGen/blob/main/figure/RQ5/RQ5_Arch_Budget_1000.jpg" width="40%"/>
</center>


### Others

- Decoding of ranking number RankNumber.
    - Decoding of RankNumber
    ![image](https://github.com/Fenking/FalBenchGen/blob/main/figure/others/RunkNumber.png)
