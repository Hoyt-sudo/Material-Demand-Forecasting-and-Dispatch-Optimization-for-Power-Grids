% 函数功能：确定0的位置,把他赋值给L
% 如果知道每一条染色体0的位置，我们就可以将每一辆车的路径与染色体片段对应起来，方便求解目标函数,
% 在本程序中即更加方便求解适应度
function L=ostation(k,s)
[NIND,~] = size(s);
L = zeros(NIND,k+1);   % 此处将4改为k+1，尽量避免硬编码
for i = 1:NIND
    L(i,:) = find(s(i,:) == 0);
end