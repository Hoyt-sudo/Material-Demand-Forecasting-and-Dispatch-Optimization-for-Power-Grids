% 保留父代精英个体
function [new_s,best_s,best_fit]=reins(s,smut,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D,NIND)
ss = [s;smut];
[fit,ff] = fitness(ss,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D);
% 取原种群与经交叉变异后得到的种群中最优的NIND个个体
[~,index] = sort(fit,'descend');

new_s = ss(index(1:NIND),:);   % 按适应度从小到大排序的个体
new_fit = fit(index(1:NIND));

best_s = ss(index(1),:);   % 这一代最佳染色体
best_fit = fit(index(1));   % 这一代最优适应度
end