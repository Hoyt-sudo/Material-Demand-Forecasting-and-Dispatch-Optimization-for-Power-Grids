% 该函数用于计算到达每一个客户点的时间
% 主要参考的内容在论文37页上半部分
function T = my_time(NIND,m,k,s,ET,speed,TT,D) 
T = zeros(NIND,m);   % 用以记录每个解中每个需求点的供货车辆到达时间
for i = 1:NIND
    time_spend = 0;  % 满足式4.12，从配送中心出发的时间是0时刻
    for j = 1:m+k+1  % 遍历染色体的每个基因
        if s(i,j) ~= 0
            % 到达时间 = 已经花费的时间(离开上一个点的时间)+运输时长，满足4.15
            T(i,s(i,j)) = time_spend + D(s(i,j-1)+1,s(i,j)+1)/speed; % 满足式4.13
            % 离开目前这个点的时间=到达时间+早到停留时长+客户停留时长(TT)，满足4.14与4.16
            time_spend = T(i,s(i,j)) + max(ET(s(i,j))-T(i,s(i,j)),0) + TT(s(i,j)) ;
        else   % 如果s(i,j)==0，说明换了辆车，已花费时间就要清零
            time_spend = 0;
        end 
    end
end
end