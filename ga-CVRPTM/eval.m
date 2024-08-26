%%----评估粒子---%%
%是否为可行解--判断依据：各车辆是否超重超重
%根据目标函数计算目标值，找出粒子群的gbest和各粒子的pbest
%i,j,k,c,t,j1,j2
function [gbestXv gbestXr fav]=eval(Xv,Xr,y,PE,PL,CT,ST,g,vn,n,m,speed,DS,w)
fav=zeros(n,1);   %%%
bm=linspace(1,n,n); 
ET=CT(:,1);
LT=CT(:,2);
g;
t1=0;
for i=1:n
    Xvi=Xv(i,:);  %获取任务对应车辆编号的粒子行
    Xri=Xr(i,:);   %获取车辆对应任务顺序行
    st=zeros(vn+1,m);
    st(1,:)=linspace(1,m,m);
    t=0;
    bmzys=zeros(1);
    sg=zeros(1,vn); %存储没辆车的货物
    ST1=zeros(1,vn);%存储每辆车的时间惩罚
    juli=zeros(1,vn);
    %对每个粒子的Xv和Xr进行解码
    for j=1:vn
        colv=find(Xvi==j);
        for k=1:length(colv)
            st(j+1,colv(k))=Xri(colv(k)); %获取每一辆车的Xr值
        end
        st0=st(1,:)';
        stj=st(j+1,:)';
        sst=[st0 stj];
        pxst=sortrows(sst,2);  %%进行排序,获取每辆车接送任务的顺序
        for c=1:m
            if pxst(c,2)~=0
                t=t+1;
                cxh(t)=pxst(c,1);  %获取每辆车的进行各项任务的编号
            end
        end
        for j1=1:t
            sg(j)=sg(j)+g(cxh(j1));   %%每辆车所载货物
            if j1~=t
                juli(j)=juli(j)+DS(1,cxh(1))+DS(cxh(j1),cxh(j1+1));  %每辆车途经距离
            else
                juli(j)=juli(j)+DS(cxh(t),1);  %每辆车途经距离
            end
            if t~=1
                if j1~=t
                cxh(j1+1);
                cxh(j1);
                  ST0=DS(1,cxh(1))/speed+ST(cxh(1))+PE*max(ET(cxh(1))-ST(1),0)+PL*max(LT(cxh(1))-ST(1),0);  %每辆车途经第一个节点时的时间（不包括时间惩罚）
                  ST1(j)=ST0+ST1(j)+DS(cxh(j1),cxh(j1+1))/speed+PE*max(ET(cxh(j1+1))-ST1(j),0)+PL*max(LT(cxh(j1+1))-ST1(j),0)+ST(cxh(j1));
                else
                    ST1(j)=ST1(j)+DS(cxh(t),1)/speed;
                end
            else
                ST0=DS(1,cxh(1))/speed+ST(cxh(1))+PE*max(ET(cxh(1))-ST(1),0)+PL*max(LT(cxh(1))-ST(1),0);
                ST1(j)=ST0;
            end
        end
        if sum(sg)>w  %%约束条件判断
            t1=t1+1;
           bmzys(t1)=j;
        end
    end
    %%%目标函数计算
    fav(i)=y*sum(juli)+sum(ST1);
end
bmzyscl=find(bmzys~=0);  %%读取不满足约束的粒子
for j3=1:length(bmzyscl)
    bm(bmzys(bmzyscl(j3)))=0;
    fav(bmzys(bmzyscl(j3)))=inf;
end
bm1=bm(bm~=0);
for j4=1:length(bmzyscl)
    lh=length(bm1);
    lh1=round(rand*(lh-2)+1);
    Xv(j4,:)=Xv(lh1,:);
end
gbestj=find(fav==min(fav));
gbestXr=Xr(gbestj,:);
gbestXv=Xv(gbestj,:);     