% Есть 15 изделий, имеющих срок службы и ресурс до кап. ремонта.
% Дата изготовления изделий различается в пределах года.
% Ремонт длится 1 год.
% Можно превысить срок службы на два года, а ресурс на 200 часов.
% Необходимо распределить даты отправки в ремонт так, чтобы в эксплуатации оставалось 5 (или максимум) единиц.

include "globals.mzn";

int: res = 750;
int: srok = 120;

var int: res_max;

constraint
res_max <= 1200 /\ res_max >= 1000;

var int: srok_max = 144;

constraint
srok_max >= 140 /\ srok_max <= 152;

int: res_incr = 20; % operation time increment per month

var int: rem_time; 

constraint
rem_time <= 14 /\ rem_time >= 8;

float: res_incr_price = 0.01; % per 1 h of res increase
int: rem_time_decr = 5; % per 1 month of repair of time decrease
int: srok_max_incr = 2; % per 1 month of expl time incr
int: stay_decr = 10; % per 1 machine staying decrease
float: res_unused = 0.03; % penalty for unused 1h of op_time

int: n = 15;
set of int: dev = 1..n;
var int: stay;

constraint
stay >= 4 /\ stay <= 10;

array[dev] of int: op_time = [300, 250, 350, 450, 650, 670, 660, 220, 250, 670, 190, 560, 340, 370, 360]; % at the moment when 10 years expire

array[dev] of int: prod_date = [11, 0, 14, 0, 0, 2, 2, 2, 4, 4, 4, 5, 9, 9, 14]; 

array[dev] of var int: rem_date;

array[dev] of var int: return_date;

% array[dev] of var int: rd_sort = sort(rem_date);

array[dev] of var int: rem_res;

constraint
forall(i in dev)(rem_date[i] <= srok_max + prod_date[i] /\ rem_date[i] >= srok  + prod_date[i]);

constraint
forall(i in rem_date, j in op_time)((i - srok)*res_incr + j <= res_max);

constraint
forall(i in dev)(return_date[i] = rem_date[i] + rem_time);

constraint
forall(i in dev)(card({rem_date[j] | j in dev where return_date[i] <= rem_date[j]+12})>=stay);

constraint
forall(i in dev)(rem_res[i] = op_time[i] + (rem_date[i] - srok)*res_incr);


array[dev] of var float: res_penalty;

constraint
forall(i in dev)(res_penalty[i] = (rem_res[i]-res)*res_incr_price);


% constraint
% forall(i in dev)(if rem_res[i]<=res then res_penalty[i] = (res-rem_res[i])*res_unused else res_penalty[i] = (rem_res[i]-res)*res_incr_price endif);

solve satisfy;

% solve maximize sum(i in dev)(rem_res[i]);

output [
show(rem_date), show(res_penalty)
]

% для каждого месяца между 120 и 134 (или больше) проверяем, находится ли вертолет на месте (то есть текущий месяц меньше, чем 
% месяц отправки, либо больше месяца возвращения).
% такх вертолетов должно быть не меньше 5 штук
  