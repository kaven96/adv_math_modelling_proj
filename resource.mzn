% Есть 15 изделий, имеющих срок службы и ресурс до кап. ремонта.
% Дата изготовления изделий различается в пределах года.
% Ремонт длится 1 год.
% Можно превысить срок службы на два года, а ресурс на 200 часов.
% Необходимо распределить даты отправки в ремонт так, чтобы в эксплуатации оставалось 5 (или максимум) единиц.

include "globals.mzn";

int: res = 750;
int: srok = 120;

int: res_max = 1000;
int: srok_max = 144;
int: res_incr = 20; % operation time increment per month
int: rem_time = 12; 

int: n = 15;
set of int: dev = 1..n;

array[dev] of int: op_time = [300, 250, 350, 450, 650, 670, 660, 220, 250, 670, 190, 560, 340, 370, 360]; % at the moment when 10 years expire

array[dev] of int: prod_date = [11, 0, 14, 0, 0, 2, 2, 2, 4, 4, 4, 5, 9, 9, 14]; 

array[dev] of var int: rem_date;

constraint
forall(i in rem_date)(i <= srok_max /\ i >= srok);

constraint
forall(i in rem_date, j in op_time)((i - srok)*res_incr + j <= res_max);

constraint
card({rem_date[i]

solve satisfy;
  