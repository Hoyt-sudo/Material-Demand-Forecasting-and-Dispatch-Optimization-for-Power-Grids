% 适应度函数
% 目标函数 = 运输成本+惩罚成本+超载成本（最后一项为电量不足产生的成本，在这里不再计算）
% 其中超载出现的原因为交叉或变异，初始化生成的一定不会超载
% 以上内容参考自5.2.3
function [fit,ff] = fitness(s,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D)
%% 初始化
M = 1000000;    % M为很大的数，作为约束条件的惩罚因子
[NIND,~] = size(s);    % 这个NIND可以不是种群的大小
d = zeros(NIND,1);  % 运输距离
overload = zeros(NIND,k);   % 是否超载

%% 适应度计算
% 运输总路程
for i = 1:NIND
    for j = 1:m+k
        d(i) = d(i) + D(s(i,j)+1,s(i,j+1)+1);
    end
end

% 惩罚成本
pun = punish(s,C1,C2,LT,ET,m,k,speed,TT,D);

% k辆车的载重量
L = ostation(k,s);
for i = 1:NIND
    for j = 1:k   % 计算k辆车的运载量
        % 这个计算起来比较复杂，一下子讲不清楚，所以得先自己理解一下
        upload(i,j) = sum(q(s(i,L(i,j)+1:L(i,j+1)-1)+1));  % 计算第j辆车的运载量
        % 判断是否超载，主要是方便后面计算目标函数
        overload(i,j) = max(upload(i,j)-Qk,0);
    end
end

% 总成本，最后一项为k辆车总的超重成本
f = Ck*d + pun +  sum(M*overload,2);    % 列向量求和运算
% 适应度
fit = 1./f;
% 真实的目标函数（不包含惩罚项）
ff = Ck*d + pun;