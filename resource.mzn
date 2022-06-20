% Есть 15 изделий, имеющих срок службы и ресурс до кап. ремонта.
% Дата изготовления изделий различается в пределах года.
% Ремонт длится 1 год.
% Можно превысить срок службы на два года, а ресурс на 200 часов.
% Необходимо распределить даты отправки в ремонт так, чтобы в эксплуатации оставалось 5 (или максимум) единиц.

include "globals.mzn";

int: res = 750;
int: srok = 120;

int: res_max = 1200;
int: srok_max = 150;
int: res_incr = 20; % operation time increment per month
int: rem_time = 8; 

int: n = 15;
set of int: dev = 1..n;

array[dev] of int: op_time = [300, 250, 350, 450, 650, 670, 660, 220, 250, 670, 190, 560, 340, 370, 360]; % at the moment when 10 years expire

array[dev] of int: prod_date = [11, 0, 14, 0, 0, 2, 2, 2, 4, 4, 4, 5, 9, 9, 14]; 

array[dev] of var int: rem_date;

array[dev] of var int: return_date;

% array[dev] of var int: rd_sort = sort(rem_date);

array[dev] of var int: rem_res;

constraint
forall(i in dev)(rem_date[i] <= srok_max + prod_date[i] /\ rem_date[i] >= srok  + prod_date[i] - 3);

constraint
forall(i in rem_date, j in op_time)((i - srok)*res_incr + j <= res_max);

% constraint
% card({rem_date[i] | i in dev where rem_date[i] > 146 /\ rem_date[i] <= 158}) <= 5;

% constraint
% card({rem_date[i] | i in dev where rem_date[i] > 134 /\ rem_date[i] <= 146}) <= 5;

% constraint
% card({rem_date[i] | i in dev where rem_date[i] > 122 /\ rem_date[i] <= 134}) <= 5;

constraint
forall(i in dev)(return_date[i] = rem_date[i] + rem_time);

% constraint
% forall(i in 120..158)(card({rem_date[j] | j in dev where rem_date[j] <= i \/ return_date[j] >= i+12}) >=10);

constraint
forall(i in dev)(card({rem_date[j] | j in dev where return_date[i] <= rem_date[j]+12})>=5);

constraint
forall(i in dev)(rem_res[i] = op_time[i] + (rem_date[i] - srok)*res_incr);

solve satisfy;

% solve maximize sum(i in dev)(rem_res[i]);

output [
show(rem_date), show(rem_res)
]

% для каждого месяца между 120 и 134 (или больше) проверяем, находится ли вертолет на месте (то есть текущий месяц меньше, чем 
% месяц отправки, либо больше месяца возвращения).
% такх вертолетов должно быть не меньше 5 штук
  