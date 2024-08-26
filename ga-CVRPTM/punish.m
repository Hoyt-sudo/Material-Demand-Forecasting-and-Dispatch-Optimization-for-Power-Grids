% 惩罚函数
% 惩罚成本的计算公式见论文14页的2.9
function pun = punish(s,C1,C2,LT,ET,m,k,speed,TT,D)
[NIND,~] = size(s);
%% 参数设置
pun = zeros(NIND,1);
T = my_time(NIND,m,k,s,ET,speed,TT,D);   % 计算到达每一个点的时刻

%% 惩罚计算
for i = 1:NIND
    for j = 1:m    % 这里j是对m各需求点按序号进行遍历
        % 已有的惩罚加上当前点(第j个)产生的惩罚，而惩罚分早到与晚到两种，根据式4.21算得
        pun(i) = pun(i) + C1*max(ET(j)-T(i,j),0) + C2*max(T(i,j)-LT(j),0);
    end
end