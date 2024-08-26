% 交叉
function scro = cro(s,m,pc,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D)
%% 初始化
[NIND,~] = size(s);
scro=zeros(NIND,m+k+1);

%% 交叉
for i = 1:2:NIND-1  
    % 选择的两个父代染色体的索引
    seln=sel(m,Ck,C1,C2,LT,ET,s,Qk,q,k,speed,TT,D);
    % 两个父代染色体
    scro(i,:) = s(seln(1),:);
    scro(i+1,:) = s(seln(2),:);
    % 两个父代染色体0的位置
    L = ostation(k,scro(i:i+1,:));
    if pc > rand
        path = zeros(2,m+k+1);
        %% Step1: 分别在两个父代染色体上随机选择一段子路经
        path_num1 = round(1 + rand*(k-1));  % 生成1,2,3,...k中的某一个
        path_num2 = round(1 + rand*(k-1));
        path_elc1 = scro(i,L(1,path_num1):L(1,path_num1+1));
        path_elc2 = scro(i+1,L(2,path_num2):L(2,path_num2+1));
        
        %% Step2：被选择的子路段前置
        % 备份scro
        scro_copy1 = scro(i,:);
        scro_copy2 = scro(i+1,:);   
        % 父代染色体1
        path(1,1:length(path_elc1)) = path_elc1;
        scro(i,1:length(path_elc1)) = path_elc1; % 被选中的段落移前面去
        scro_copy1(L(1,path_num1):L(1,path_num1+1)-1) = [];  % 删除前移部分，还要-1是因为得留下一个0
        scro(i,length(path_elc1):end) = scro_copy1;   % 剩下部分在后面接上去
        
        % 父代染色体2
        path(2,1:length(path_elc2)) = path_elc2;
        scro(i+1,1:length(path_elc2)) = path_elc2;
        scro_copy2(L(2,path_num2):L(2,path_num2+1)-1) = [];
        scro(i+1,length(path_elc2):end) = scro_copy2;
        
        %% Step3：参见论文43页最下方，以下步骤得到的path的后两个一定为0
        % 补全子染色体1
        for j = 1:m+k-1-length(path_elc1)   % 后面还有两个0的位置，故为m+k+1-2
            for ij = 2:m+k   % 遍历子染色体2，从第2个遍历到倒数第二个
                if length(find(path(1,:) == scro(i+1,ij))) == 0    % 如果被遍历的位置对应的需求点没在1当中
                    path(1,length(path_elc1)+j) = scro(i+1,ij);
                    break;
                end
            end
        end
        % 补全子染色体2
        for j = 1:m+k-1-length(path_elc2)
            for ij = 2:m+k   % 遍历子染色体1
                if length(find(path(2,:) == scro(i,ij))) == 0   
                    path(2,length(path_elc2)+j) = scro(i,ij);
                    break;
                end
            end
        end
        %% Step4：选择一个最好的位置插入0
        % 子染色体1
        best_fit1 = 0;
        best_s1 = zeros(1,m+k+1);
        path_copy = path;
        for j = 1:m+k-2-length(path_elc1) % 0不能连着存在，因此有3个位置不能插入0
            % path_copy自插入位置(length(path_elc1)+1+j)开始，后面的那些非0数统一往后移1位
            path_copy(1,length(path_elc1)+1+j+1:m+k) = path(1,length(path_elc1)+1+j:m+k-1);
            % 插入位置为0
            path_copy(1,length(path_elc1)+1+j) = 0;
            % 插入位置之前的部分照常放
            path_copy(1,1:length(path_elc1)+j) = path(1,1:length(path_elc1)+j);
            % 求此时的适应度
            [fit,~] = fitness(path_copy(1,:),m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D);
            if fit > best_fit1   % 如果插更换入0的位置之后适应度更大，则更新最优解
                best_fit1 = fit;
                best_s1 = path_copy(1,:);
            end
        end
        % 子染色体2
        best_fit2 = 0;
        best_s2 = zeros(1,m+k+1);
        for j = 1:m+k-2-length(path_elc2) % 0不能连着存在，因此有3个位置不能插入0
            ind = length(path_elc2)+1+j;% 记录插入位置
            % path_copy自插入位置ind开始，后面的那些非0数统一往后移1位
            path_copy(2,ind+1:m+k) = path(2,ind:m+k-1);
            path_copy(2,ind) = 0;
            path_copy(2,1:ind-1) = path(2,1:ind-1);
            [fit,~] = fitness(path_copy(2,:),m,Ck,C1,C2,LT,ET,Qk,q,k,speed,TT,D);
            if fit > best_fit2   
                best_fit2 = fit;
                best_s2 = path_copy(2,:);
            end
        end
        
        path = [best_s1;best_s2];
        scro(i:i+1,:) = path;
    end
end
end