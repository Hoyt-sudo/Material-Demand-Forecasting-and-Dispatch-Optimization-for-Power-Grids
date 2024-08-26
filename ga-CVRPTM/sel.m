% 选择
% sel_num为选择的个体数目，该函数返回两个索引值
function seln = sel(m,Ck,C1,C2,LT,ET,s,Qk,q,k,speed,TT,D)

sel_num = 2;   % 被选择的个体数目
seln = zeros(sel_num,1);  % 从种群中选择sel_num个个体

%% 选择概率的计算
% Step1：计算适应度
[fit,~] = fitness(s,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D);
% Step2-Step3:计算选择概率
fitsum = sum(fit);
p = fit/fitsum;
% Step4:计算累计概率
ps = cumsum(p);  % cumsum用于求累计和

%% 个体的选择
for i = 1:sel_num
    r = rand;
    % 找到比随机数r大的ps中的最小数对应的下标
    ind = min(find(ps > r));
    % 如果ind还没有被选择过的话才可以被选
    while length(find(seln == ind)) ~= 0   % seln中至少有一个值为ind，说明被选中过，那么要重新选
        r = rand;
        ind = min(find(ps > r));
    end
    seln(i) = ind;
end