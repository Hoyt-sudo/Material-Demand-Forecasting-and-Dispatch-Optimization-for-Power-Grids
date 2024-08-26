function error = fitness(x,inputnum,hiddennum_best,outputnum,net,inputn,outputn,output_train,inputn_test,outputps,output_test)
%�ú�������������Ӧ��ֵ
hiddennum=hiddennum_best;
%��ȡ
setdemorandstream(pi);

w1=x(1:inputnum*hiddennum);%ȡ������������������ӵ�Ȩֵ
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);%��������Ԫ��ֵ
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);%ȡ������������������ӵ�Ȩֵ
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);%�������Ԫ��ֵ

net.trainParam.showWindow=0;  %���ط������

%����Ȩֵ��ֵ
net.iw{1,1}=reshape(w1,hiddennum,inputnum);%��w1��1��inputnum*hiddennum��תΪhiddennum��inputnum�еĶ�ά����
net.lw{2,1}=reshape(w2,outputnum,hiddennum);%���ľ���ı����ʽ
net.b{1}=reshape(B1,hiddennum,1);%1��hiddennum�У�Ϊ���������Ԫ��ֵ
net.b{2}=reshape(B2,outputnum,1);

%����ѵ��
net=train(net,inputn,outputn);

an0=sim(net,inputn);
train_simu=mapminmax('reverse',an0,outputps);
an=sim(net,inputn_test);
test_simu=mapminmax('reverse',an,outputps);

error=mse(output_test,test_simu);   %��Ӧ�Ⱥ���ѡȡΪ���Լ��ľ�������Ӧ�Ⱥ���ֵԽС������ģ�͵�Ԥ�⾫��Խ�ߣ�ע��newff�������BP�������˽�����֤�����ѡ���������Ԥ�������Ϊ��Ӧ�Ⱥ����Ǻ���
%error=(mse(output_train,train_simu)+mse(output_test,test_simu))/2; %��Ӧ�Ⱥ���ѡȡΪѵ��������Լ�����ľ������ƽ��ֵ����Ӧ�Ⱥ���ֵԽС������ѵ��Խ׼ȷ���Ҽ��ģ�͵�Ԥ�⾫�ȸ��á�



