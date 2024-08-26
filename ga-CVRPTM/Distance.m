%计算两两需求点之间的欧式距离
function D = Distance(X)
row = size(X,1);   % 城市个数（在这里是k+m）
D = zeros(row,row);
for i = 1:row
    for j = i+1:row
        D(i,j) = ((X(i,1) - X(j,1))^2 + (X(i,2) - X(j,2))^2)^0.5;
        D(j,i) = D(i,j);
    end
end