RF-HRV-Reproduction：基于射频信号的心脏活动监测论文复现
一、项目简介
本项目围绕 2024 年发表于 Nature Communications 的论文《Monitoring Long-term Cardiac Activity with Contactless Radio Frequency Signals》开展 MATLAB 代码复现与实验分析。
该研究利用射频（Radio Frequency，RF）信号，在不直接接触人体的情况下监测心脏活动，并从雷达信号中提取心搏间期（Inter-Beat Interval，IBI），进一步计算心率变异性（Heart Rate Variability，HRV）相关指标。
本项目基于论文配套 MATLAB Demo 代码及最小数据集，运行信号处理与特征提取流程，并对实验误差进行统计和可视化分析。
二、论文信息
论文标题： Monitoring Long-term Cardiac Activity with Contactless Radio Frequency Signals
发表期刊： Nature Communications
发表年份： 2024
论文链接： https://www.nature.com/articles/s41467-024-55061-9
三、技术栈与方法
编程语言： MATLAB
信号处理： 变分模态分解（Variational Mode Decomposition，VMD）
心搏检测： 基于峰值检测函数 findpeaks 提取心搏时刻
数据处理： 雷达信号处理、心搏间期计算及异常值处理
评价指标：
    RT-IBI Error：实时心搏间期误差
    RMSSD Error：相邻心搏间期差值均方根相关误差
    SDRR Error：心搏间期标准差相关误差
    pNN50 Error：相邻心搏间期差值超过指定阈值的比例误差
可视化： 箱线图与误差统计表
四、仓库文件说明
文件或目录	说明
RF_HRV.m	MATLAB 论文复现主程序
Minimum_dataset/	运行程序所需的预处理最小数据集，本仓库暂不公开该数据集
HRV_error_boxplots.png	四项 HRV 误差指标的箱线图
HRV_error_summary.csv	四项误差指标的统计汇总
RT_IBI_error_all.png	RT-IBI 误差箱线图
RT_IBI_error_all.csv	RT-IBI 误差数据
results/	实验结果文件目录（如有）
五、复现流程
1. 在 MATLAB 或 MATLAB Online 中打开 RF_HRV.m。
2. 将 Minimum_dataset 文件夹放在主程序能够访问的位置，并确认代码中的数据路径正确。
3. 确认 MATLAB 环境支持代码所使用的函数，包括 vmd 和 findpeaks。
4. 运行主程序，依次读取数据集中的样本并进行雷达信号处理。
5. 提取心搏间期，计算相关 HRV 指标的误差。
6. 生成误差统计数据和箱线图，对实验结果进行分析。
六、实验结果
本次实验使用预处理最小数据集中的 20 个样本运行 MATLAB 程序。
当前已完成以下工作：
完成主程序运行；
得到四项误差指标的实验数据，每项指标包含 20 个样本的结果；
生成四项误差指标的箱线图；
生成误差统计汇总表，并对误差较大的样本进行了初步检查。
具体统计结果以仓库中提交的 CSV 文件和实验图表为准。
七、复现范围与局限性
本项目目前主要完成论文配套 MATLAB Demo 在最小数据集上的运行与结果分析，属于对论文部分流程的复现，不代表已经完整复现论文中的全部实验、长期监测结果或临床对照实验。
目前的复现结果仍需结合论文原文中的实验设置和评价标准进行进一步核对。由于使用的是预处理数据，且尚未独立验证所有实验环节，结果与论文原文可能存在差异。
八、数据说明
本项目使用的最小数据集包含经过预处理的雷达数据与心搏间期真实值。考虑到患者隐私，暂不在公开 GitHub 仓库中上传相关数据文件。
如需运行程序，请确保已通过合规渠道获得相应数据，并遵守数据使用及隐私保护要求。
九、参考文献
Zhang, B., Zhang, D., Li, Y., et al. Monitoring Long-term Cardiac Activity with Contactless Radio Frequency Signals. Nature Communications, 2024.
论文链接：https://www.nature.com/articles/s41467-024-55061-9
