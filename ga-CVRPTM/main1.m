%%—————粒子群算法求解带时间窗的车辆路径规划问题——————%%%
clc
clear all
close all
%% 目标约束初始化
%同时需要给出距离矩阵（DS）--DS
DS=load('算法求解\DS.mat');
DS=struct2cell(DS);
DS=cell2mat(DS);
%车辆速度（speed)
speed=50;  
%各任务的时间窗([ETi,LTi])---CT
CT=load('算法求解\CT.mat');
CT=struct2cell(CT);
CT=cell2mat(CT);
%服务时间（STi)--ST
ST=load('算法求解\ST.mat');
ST=struct2cell(ST);
ST=cell2mat(ST);
%车辆容量（W）
w=7.5; 
%各场点的货运量（gi)--g
g=load('算法求解\g.mat');
g=struct2cell(g);
g=cell2mat(g);
%运输成本矩阵y（与运输距离成正比）
y=3;
%定义目标函数的罚金成本PE,PL
PE=50;%早到时间惩罚
PL=50; %到达加上该场点的服务时间达到LT的惩罚
%% 粒子初始化
n=40;  %粒子规模
c1=1.49; %参数1
c2=2.33;  %参数2
m=9;   %%任务数
cdm=linspace(1,m,m);  %%生成任务编号
vn=4;  %%总的车辆数
Xv=zeros(n,m); %各任务对应的车辆编号，为0-vn之间的整数
Xr=zeros(n,m);  %为各车辆进行各项任务的顺序
Vv=zeros(n,m);  %为车辆编号的速度
Vr=zeros(n,m);  %为任务顺序的速度
maxgen=100;     %迭代最大次数
pbestXr=zeros(n,m); %%各粒子的在历史过程中的最优解
pbestXv=zeros(n,m); %%各粒子的在历史过程中的最优解
gbestXr=zeros(1,m); %%粒子种群在历史过程中的最优
gbestXr=zeros(1,m); %%粒子种群在历史过程中的最优
%% 算法实现
%i=1时
Xv=round((rand(n,m)*(vn-1)+1));  %为0-vn之间的整数
Xr=rand(n,m)*(m-1)+1;   %为0-m之间的实数
Vv=round((rand(n,m)*(vn-3)+1));  %为0-(vn-1)之间的整数
Vr=(rand(n,m)*(m-1)+1);  %为0-(m-1)之间的实数
[gbestXv gbestXr fav]=eval(Xv,Xr,y,PE,PL,CT,ST,g,vn,n,m,speed,DS,w);  %%进行粒子评价并得到粒子的gbestXr,gbestXv
pbestXv=Xv;
pbestXr=Xr;
fav1=fav;  %评估值进行存储，用于下一状态的评价
%当i>1时
for i=2:maxgen
    Xv2=Xv;
    Xr2=Xr;
    for j=1:n
        Xv1=Xv(j,:);
        Xr1=Xr(j,:);
        Vv1=Vv(j,:);
        Vr1=Vr(j,:);
        Vv(j,:)=round(Vv1+c1*rand*(pbestXv(j,:)-Xv1)+c2*rand*(gbestXv-Xv1));  %%各任务对应的车辆速度更新
        Vr(j,:)=Vr1+c1*rand*(pbestXr(j,:)-Xr1)+c2*rand*(gbestXr-Xr1);  %%车辆接受各任务的序号的速度更新
        %%%速度校正
        Vvsz=Vv(j,:);
        Xvsz=Xv(j,:);
        Vrsz=Vr(j,:);
        Xrsz=Xr(j,:);
        for j1=1:m
            if Vvsz(j1)>vn-1 |  Vrsz>m-1
                Vvsz(j1)=vn;
                Vrsz(j1)=m-1;
            elseif Vvsz(j1)<1-vn | Vrsz<1-m
                Vvsz(j1)=1-vn;
                Vrsz(j1)=1-m;
            end
        end
        %%%位置校正
        Xv(j,:)=Xv(j,:)+Vv(j,:);  %%各任务对应的车辆序号位置更新
        Xr(j,:)=Xr(j,:)+Vr(j,:);  %%各车辆进行各项任务顺序的位置更新
    %------------------------------------%%
        if Xvsz(j1)<=0 |  Xrsz<1-m
                Xvsz(j1)=1;
                Xrsz(j1)=rand*(1-m);
        elseif Xvsz(j1)>vn | Xrsz>m-1
                 Xvsz(j1)=round(rand*(vn)+1);
                 Xrsz(j1)=rand*(m-1);
        end
        Vv(j,:)=Vvsz;
        Xv(j,:)= Xvsz;
        Vr(j,:)=Vrsz;
        Xr(j,:)= Xrsz;
    end
     [gbestXv gbestXr fav]=eval(Xv,Xr,y,PE,PL,CT,ST,g,vn,n,m,speed,DS,w);  %%进行粒子评价
     for k=1:n
         if fav(k)<=fav1(k)
             pbestXv(k,:)=Xv(k,:);
             pbestXr(k,:)=Xr(k,:);
         else
             pbestXv(k,:)=Xv2(k,:);
             pbestXr(k,:)=Xr2(k,:);
         end
     end
     fav1=fav;
end
gbestXv;
min(fav);
gbestXr;
%% 最优粒子解码
zuiyou=zeros(vn+1,m);
zuiyou(1,:)=linspace(1,m,m);
xh=0;
    for i=1:vn
        colv1=find(gbestXv==i);
        for j=1:length(colv1)
            zuiyou(i+1,colv1(j))=gbestXr(colv1(j));
        end
        zy0=zuiyou(1,:)';
        zy1=zuiyou(i+1,:)';
        zy2=[zy0 zy1];
        szy=sortrows(zy2,2);
        szy=szy';
        t=0;
        for k=1:m
            if szy(2,k)~=0
               % xh
                t=t+1;
                szy(1,k);
                xh(t)=szy(1,k);
            end
        end
        xh;
        st=0;
        st=num2str(st);
  %% 结果输出
          for d=1:length(xh)
                strr=num2str(xh(d));
                strr=strcat(strr,'->');
                st=[st,'->', strr];
          end
          st1=0;
          st1=num2str(st1);
          st=[st,st1];
        disp(['第',num2str(i),'辆车','的运输路线为：',num2str(st)])
        xh=0;
    end
    disp(['目标最优值为：',num2str(min(fav))])