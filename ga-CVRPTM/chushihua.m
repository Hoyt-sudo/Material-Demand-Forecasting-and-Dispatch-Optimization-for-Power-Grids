% 生成初始种群
% 函数说明：
% 染色体长度为m+k+1，其中m为客户点数目，k为车辆数目，加1是因为第一个位置为配送中心，数值为0
% 具体的染色体编码与解之间的关系见论文41页的5.2.1部分
% 种群初始化时需插入k个0，这样子可以满足式4.10和4.11，具体插入方式见42页5.2.2，5.2.2可以满足式4.9
function s = chushihua(NIND,m,k,q,Qk)

%% 生成NIND个配送中心，这是放在第一列的
center = zeros(NIND,1);

%% 生成长度为m+k的染色体，用以表示车辆配送路径设置
path_center = zeros(NIND,m+k);  % 这样的好处一方面加速运行，另一方面保证每一行最后一个数一定为0
for i = 1:NIND
    % 初始的，使用randperm可以保证每个客户点能且仅能被服务一次，即满足式4.8
    path = randperm(m);  
    % 插入k个0
    upload = 0;  % 当前这辆车已载货物量
    kk = 0;     % 已使用的车辆数
    for j = 1:m
        if upload + q(path(j)+1) <= Qk  % q的索引为path(j)+1是因为q的第一个数字为配送中心
            path_center(i,j+kk) = path(j); % 第j个需求点应该放在第j-1+kk+1的位置上
            upload = upload + q(path(j)+1);
        else    % 当当前车辆已经载货量已达到上限，需要更换一辆车了
            path_center(i,j+kk) = 0;   % 加kk的原因同上
            path_center(i,j+kk+1) = path(j);   % 这个再加1因为是放在0的后面
            kk = kk+1;
            upload = q(path(j)+1);
        end
    end
end

%% 合并，s的第一列和最后一列都是0，即满足式4.7
s = [center,path_center];