% 变异操作
function smut = mut(s,m,k,Ck,C1,C2,LT,ET,Qk,q,speed,TT,pm,D)
[NIND,col] = size(s);  % col = m+k+1
smut = s;
ss = zeros(6,col);
%% 变异
% 不妨记三个位置为1,2,3
for i = 1:NIND
    if pm > rand
        %% 找出三个交换的位置
        r = randperm(m);
        exchange_num = r(1:3);   % 随机序列的前3个作为交换位置
        ind_1 = find(s(i,:) == exchange_num(1));   % 1
        ind_2 = find(s(i,:) == exchange_num(2));   % 2
        ind_3 = find(s(i,:) == exchange_num(3));   % 3

        ss(1,:) = s(i,:);
        %% 5种情况
        % 1,3,2
        ss(2,:) = exchange(s(i,:),ind_2,ind_3);
        % 2,1,3
        ss(3,:) = exchange(s(i,:),ind_1,ind_2);
        % 2,3,1
        ss(4,:) = exchange(s(i,:),ind_1,ind_2);
        ss(4,:) = exchange(ss(4,:),ind_2,ind_3);
        % 3,1,2
        ss(5,:) = exchange(s(i,:),ind_1,ind_3);
        ss(5,:) = exchange(ss(5,:),ind_2,ind_3);
        % 3,2,1
        ss(6,:) = exchange(s(i,:),ind_1,ind_3);
        %% 找到5种情况里最好的
        [fit,~] = fitness(ss,m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D);
        [~,ind_max] = max(fit);
        smut(i,:) = ss(ind_max,:);
    end
end
end