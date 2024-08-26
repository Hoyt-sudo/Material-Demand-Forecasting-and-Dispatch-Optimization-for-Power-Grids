%% ��ʼ��
clear
close all
clc
warning off

%% ���ݶ�ȡ
data=xlsread('data.xls','Sheet1','A1:E48'); %%ʹ��xlsread������ȡEXCEL�ж�Ӧ��Χ�����ݼ���

%�����������
input=data(:,1:end-1);    %data�ĵ�һ��-�����ڶ���Ϊ����ָ��
output=data(:,end);  %data�������һ��Ϊ�����ָ��ֵ

N=length(output);   %ȫ��������Ŀ
testNum=8;   %�趨����������Ŀ
trainNum=N-testNum;    %����ѵ��������Ŀ

%% ����ѵ���������Լ�
input_train = input(1:trainNum,:)';
output_train =output(1:trainNum)';
input_test =input(trainNum+1:trainNum+testNum,:)';
output_test =output(trainNum+1:trainNum+testNum)';

%% ���ݹ�һ��
[inputn,inputps]=mapminmax(input_train,0,1);
[outputn,outputps]=mapminmax(output_train);
inputn_test=mapminmax('apply',input_test,inputps);

%% ��ȡ�����ڵ㡢�����ڵ����
inputnum=size(input,2);
outputnum=size(output,2);
disp('/////////////////////////////////')
disp('������ṹ...')
disp(['�����Ľڵ���Ϊ��',num2str(inputnum)])
disp(['�����Ľڵ���Ϊ��',num2str(outputnum)])
disp(' ')
disp('������ڵ��ȷ������...')

%ȷ��������ڵ����
%���þ��鹫ʽhiddennum=sqrt(m+n)+a��mΪ�����ڵ������nΪ�����ڵ������aһ��ȡΪ1-10֮�������
MSE=1e+5; %��ʼ����С���
for hiddennum=fix(sqrt(inputnum+outputnum))+1:fix(sqrt(inputnum+outputnum))+10
    
    %��������
    net=newff(inputn,outputn,hiddennum);
    % �������
    net.trainParam.epochs=1000;         % ѵ������
    net.trainParam.lr=0.01;                   % ѧϰ����
    net.trainParam.goal=0.000001;        % ѵ��Ŀ����С���
    % ����ѵ��
    net=train(net,inputn,outputn);
    an0=sim(net,inputn);  %������
    mse0=mse(outputn,an0);  %����ľ������
    disp(['������ڵ���Ϊ',num2str(hiddennum),'ʱ��ѵ�����ľ������Ϊ��',num2str(mse0)])
    
    %������ѵ�������ڵ�
    if mse0<MSE
        MSE=mse0;
        hiddennum_best=hiddennum;
    end
end
disp(['��ѵ�������ڵ���Ϊ��',num2str(hiddennum_best),'����Ӧ�ľ������Ϊ��',num2str(MSE)])

%% �������������ڵ��BP������
disp(' ')
disp('��׼��BP�����磺')
net0=newff(inputn,outputn,hiddennum_best,{'tansig','purelin'},'trainlm');% ����ģ��

%�����������
net0.trainParam.epochs=1000;         % ѵ����������������Ϊ1000��
net0.trainParam.lr=0.01;                   % ѧϰ���ʣ���������Ϊ0.01
net0.trainParam.goal=0.00001;                    % ѵ��Ŀ����С����������Ϊ0.0001
net0.trainParam.show=25;                % ��ʾƵ�ʣ���������Ϊÿѵ��25����ʾһ��
net0.trainParam.mc=0.01;                 % ��������
net0.trainParam.min_grad=1e-6;       % ��С�����ݶ�
net0.trainParam.max_fail=6;               % ���ʧ�ܴ���

%��ʼѵ��
net0=train(net0,inputn,outputn);

%Ԥ��
an0=sim(net0,inputn_test); %��ѵ���õ�ģ�ͽ��з���

%Ԥ��������һ����������
test_simu0=mapminmax('reverse',an0,outputps); %�ѷ���õ������ݻ�ԭΪԭʼ��������
%���ָ��
[mae0,mse0,rmse0,mape0,error0,errorPercent0]=calc_error(output_test,test_simu0);

%% ��ȸ�����㷨Ѱ����Ȩֵ��ֵ
disp(' ')
disp('SSA�Ż�BP�����磺')
net=newff(inputn,outputn,hiddennum_best,{'tansig','purelin'},'trainlm');% ����ģ��

%�����������
net.trainParam.epochs=1000;         % ѵ����������������Ϊ1000��
net.trainParam.lr=0.01;                   % ѧϰ���ʣ���������Ϊ0.01
net.trainParam.goal=0.00001;                    % ѵ��Ŀ����С����������Ϊ0.0001
net.trainParam.show=25;                % ��ʾƵ�ʣ���������Ϊÿѵ��25����ʾһ��
net.trainParam.mc=0.01;                 % ��������
net.trainParam.min_grad=1e-6;       % ��С�����ݶ�
net.trainParam.max_fail=6;               % ���ʧ�ܴ���

%��ʼ��SSA����
popsize=30;   %��ʼ��Ⱥ��ģ
maxgen=50;   %����������
dim=inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum+outputnum;    %�Ա�������
lb=repmat(-3,1,dim);    %�Ա�������
ub=repmat(3,1,dim);   %�Ա�������
ST = 0.6;%��ȫֵ
PD = 0.7;%�����ߵı��У�ʣ�µ��Ǽ�����
SD = 0.2;%��ʶ����Σ����ȸ�ı���
PDNumber = popsize*PD; %����������
SDNumber = popsize - popsize*PD;%��ʶ����Σ����ȸ����
%% ��Ⱥ��ʼ��
X=zeros(popsize,dim);
for i=1:dim
    ub_i=ub(i);
    lb_i=lb(i);
    X(:,i)=rand(popsize,1).*(ub_i-lb_i)+lb_i;
end

%% �����ʼ��Ӧ��ֵ
fit = zeros(1,popsize);
for i = 1:popsize
    fit(i) =  fitness(X(i,:),inputnum,hiddennum_best,outputnum,net,inputn,outputn,output_train,inputn_test,outputps,output_test);
end

%��ʼ��ȫ�����Ÿ���
[fit, index]= sort(fit);%����
BestF = fit(1);
GBestF = fit(1);
X = X(index,:);
GBestX = X(1,:);%ȫ������λ��

%���������ĳ�ʼ��
curve=zeros(1,maxgen);
X_new = X;

%% ��ʼ�Ż�
h0=waitbar(0,'SSA optimization...');
for i = 1: maxgen
    
    BestF = fit(1);
    R2 = rand(1);  %Ԥ��ֵ
    %���·�����λ��
    for j = 1:PDNumber
        if(R2<ST)
            X_new(j,:) = X(j,:).*exp(-j/(rand(1)*maxgen));
        else
            X_new(j,:) = X(j,:) + randn()*ones(1,dim);
        end
    end
    %���¼�����λ��
    for j = PDNumber+1:popsize
        if(j>(popsize - PDNumber)/2 + PDNumber)
            X_new(j,:)= randn().*exp((X(end,:) - X(j,:))/j^2);
        else
            %����-1��1�������
            A = ones(1,dim);
            for a = 1:dim
                if(rand()>0.5)
                    A(a) = -1;
                end
            end
            AA = A'*inv(A*A');
            X_new(j,:)= X(1,:) + abs(X(j,:) - X(1,:)).*AA';
        end
    end
    %����ʳ��Ϊ������ȸλ��
    Temp = randperm(popsize);
    SDchooseIndex = Temp(1:SDNumber);
    for j = 1:SDNumber
        if(fit(SDchooseIndex(j))>BestF)
            X_new(SDchooseIndex(j),:) = X(1,:) + randn().*abs(X(SDchooseIndex(j),:) - X(1,:));
        elseif(fit(SDchooseIndex(j))== BestF)
            K = 2*rand() -1;
            X_new(SDchooseIndex(j),:) = X(SDchooseIndex(j),:) + K.*(abs( X(SDchooseIndex(j),:) - X(end,:))./(fit(SDchooseIndex(j)) - fit(end) + 10^-8));
        end
    end
    %�߽����
    for j = 1:popsize
        for a = 1: dim
            if(X_new(j,a)>ub(a))
                X_new(j,a) =ub(a);
            end
            if(X_new(j,a)<lb(a))
                X_new(j,a) =lb(a);
            end
        end
    end
    %����λ��
    fitness_new=zeros(popsize,1);
    for j=1:popsize
        fitness_new(j) = fitness(X_new(j,:),inputnum,hiddennum_best,outputnum,net,inputn,outputn,output_train,inputn_test,outputps,output_test);
    end
    for j = 1:popsize
        if(fitness_new(j) < GBestF)
            GBestF = fitness_new(j);
            GBestX = X_new(j,:);
        end
    end
    X = X_new;
    fit = fitness_new;
    %�������
    [fit, index]= sort(fit);%����
    for j = 1:popsize
        X(j,:) = X(index(j),:);
    end
    curve(i) = GBestF;
    waitbar(i/maxgen,h0)
end
close(h0)
Best_pos =GBestX;
Best_score = curve(end);
setdemorandstream(pi);
%% ���ƽ�������
figure
plot(curve,'r-','linewidth',2)
xlabel('��������')
ylabel('�������')
legend('�����Ӧ��')
title('SSA�Ľ�����������')
w1=Best_pos(1:inputnum*hiddennum_best);         %����㵽�м���Ȩֵ
B1=Best_pos(inputnum*hiddennum_best+1:inputnum*hiddennum_best+hiddennum_best);   %�м������Ԫ��ֵ
w2=Best_pos(inputnum*hiddennum_best+hiddennum_best+1:inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum);   %�м�㵽������Ȩֵ
B2=Best_pos(inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum+1:inputnum*hiddennum_best+hiddennum_best+hiddennum_best*outputnum+outputnum);   %��������Ԫ��ֵ
%�����ع�
net.iw{1,1}=reshape(w1,hiddennum_best,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum_best);
net.b{1}=reshape(B1,hiddennum_best,1);
net.b{2}=reshape(B2,outputnum,1);

%% �Ż����������ѵ��
net=train(net,inputn,outputn);%��ʼѵ��������inputn,outputn�ֱ�Ϊ�����������

%% �Ż�������������
an1=sim(net,inputn_test);
test_simu1=mapminmax('reverse',an1,outputps); %�ѷ���õ������ݻ�ԭΪԭʼ��������
%���ָ��
[mae1,mse1,rmse1,mape1,error1,errorPercent1]=calc_error(output_test,test_simu1);


%% ��ͼ
figure
plot(output_test,'b-*','linewidth',1)
hold on
plot(test_simu0,'r-v','linewidth',1,'markerfacecolor','r')
hold on
plot(test_simu1,'k-o','linewidth',1,'markerfacecolor','k')
legend('��ʵֵ','BPԤ��ֵ','SSA-BPԤ��ֵ')
xlabel('�����������')
ylabel('ָ��ֵ')
title('SSA�Ż�ǰ���BP������Ԥ��ֵ����ʵֵ�Ա�ͼ')

figure
plot(error0,'rv-','markerfacecolor','r')
hold on
plot(error1,'ko-','markerfacecolor','k')
legend('BPԤ�����','SSA-BPԤ�����')
xlabel('�����������')
ylabel('Ԥ��ƫ��')
title('SSA�Ż�ǰ���BP������Ԥ��ֵ����ʵֵ���Ա�ͼ')

disp(' ')
disp('/////////////////////////////////')
disp('��ӡ������')
disp('�������     ʵ��ֵ      BPԤ��ֵ  SSA-BPֵ   BP���   SSA-BP���')
for i=1:testNum
    disp([i output_test(i),test_simu0(i),test_simu1(i),error0(i),error1(i)])
end

