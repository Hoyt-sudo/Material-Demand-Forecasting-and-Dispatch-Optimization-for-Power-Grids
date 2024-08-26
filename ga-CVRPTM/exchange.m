% 此函数主要用于交换s两个位置的元素
function s = exchange(s,ind_1,ind_2)
t = s(ind_1);
s(ind_1) = s(ind_2);
s(ind_2) = t;
end