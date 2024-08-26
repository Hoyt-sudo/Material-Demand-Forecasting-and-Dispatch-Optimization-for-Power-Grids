%% 注意
% 不用电动汽车，然后1个运输中心，20个客户，3辆车
% time 函数的子函数，就是时间窗怎么设置，我也需要知道。
% 重点讲解ostation、chushihua函数
% 需要的结果：
% ①：路径规划与每一条路径的配送成本（起点和终点都是运输中心）
% ②：绘出路径图

clear,clc
%% 参数设置
k=3;  % 3辆车
m=20; % 20个客户点
% ch=2; % 2个充电站
% 各客户点需求量，其中配送中心需求量为0，其中q(1)为配送中心，以此类推
q = [0 0.5 0.8 0.4 0.5 0.7 0.7 0.6 0.2 0.2 0.4 0.1 0.1 0.2 0.5 0.2 0.7 0.2 0.7 0.1 0.5]; 
% 配送中心和客户点的坐标位置，配送中心在第1位
X=[ 55 55   
    40 48
    32 80
    16 69
    88 96
    48 96
    32 104
    80 56
    48 40
    24 16
    48 8
    16 32
    8 48
    32 64
    24 96
    72 104
    72 32
    72 16
    88 8
    96 56
    98 32 ];
D = Distance(X);   % 各个点之间的距离

% 时间参数
% 客户要求到货的时间始点（最早点）
ET=[3 0 7 1 4 1 3 0 2 2 7 6 7 1 1 8 6 7 6 4];
% 客户要求到货的时间终点（最晚点）
LT=[5 2 8 3 5 2 4 1 4 3 8 8 9 3 3 10 10 8 7 6];
% 客户点的停留时间
TT=[0.5 0.8 0.4 0.5 0.7 0.7 0.6 0.2 0.2 0.4 0.1 0.1 0.2 0.5 0.2 0.7 0.2 0.7 0.1 0.5]; 

% 成本参数
Ck=10; % 第k辆车运行单位距离的费用（运输成本）
C1=20; % 车辆在任务点处等待单位时间的机会成本（早到惩罚）
C2=30; % 车辆在要求时间之后到达单位时间所处的惩罚值（晚到惩罚）

% 汽车参数
Dis = 160; % 续驶里程
Qk = 4; % 车辆额定载重量
speed = 40; % 汽车的行驶速度

% 遗传算法参数
NIND = 100; % 种群大小，一般种群大小在100到200之间比较好
maxgen = 500; % 遗传代数
pc = 0.8; % 交叉概率
pm = 0.1; % 变异概率
% GGAP = 0.5;   % 代购，决定了选择操作部分选择的个体数目

%% 模型求解
s = chushihua(NIND,m,k,q,Qk); % 初始化种群
gen=0;  % 表示当前遗传代数

% 计算适应度和模型目标函数值
[~,ff] = fitness(s,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D); 
preff=min(ff);    % 初始种群的最优目标函数值
sperfect=zeros(maxgen,m+k+1); % 每一代的最优个体
best_fit = zeros(maxgen,1);   % 每一代最优适应度
while gen<maxgen
    %% 遗传算子
    % 交叉操作
    scro = cro(s,m,pc,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D);
    % 变异操作
    smut = mut(scro,m,k,Ck,C1,C2,LT,ET,Qk,q,speed,TT,pm,D);
    %% 记录并更新全局最优解
    % 重插入子代
    [s,s_gen,best_fit_gen] = reins(s,smut,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D,NIND);
    % 更新迭代次数
    gen=gen+1;
    % 记录当前代最好的染色体
    sperfect(gen,:)=s_gen;
    % 记录这一代最好的适应度
    best_fit(gen) = best_fit_gen;
%     gen
end

%% 模型输出
best_path = sperfect(end,:);
% 输出最优解的路线和最优目标函数值
disp('最优解：')
disp(best_path) % 最优路线

disp(['目标函数值：',num2str(1/best_fit(end))])

%% 绘图
% 遗传图
figure;
hold on; box on;
plot(best_fit)
xlim([0,maxgen]);   % 设置x坐标轴显示范围
title('优化过程');
xlabel('代数');
ylabel('适应度值');

% 配送路径图
figure
plot(X(1,1),X(1,2),'o','markersize',10)    % 配送中心
hold on
plot(X(2:end,1),X(2:end,2),'.','markersize',10)  % 需求点
for i = 1:m+k
    line([X(best_path(i)+1,1),X(best_path(i+1)+1,1)],[X(best_path(i)+1,2),X(best_path(i+1)+1,2)]);
end
xlabel('横坐标X')
ylabel('纵坐标Y')