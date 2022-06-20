% Есть 15 изделий, имеющих срок службы и ресурс до кап. ремонта.
% Дата изготовления изделий различается в пределах года.
% Ремонт длится 1 год.
% Можно превысить срок службы на два года, а ресурс на 200 часов.
% Необходимо распределить даты отправки в ремонт так, чтобы в эксплуатации оставалось 5 (или максимум) единиц.

include "globals.mzn";

int: res = 750;
int: srok = 120;

int: res_max = 1000;

var int: srok_max;

constraint
srok_max >= 144 /\ srok_max <= 152;

int: res_incr = 20; % operation time increment per month

var int: rem_time; 

constraint
rem_time <= 14 /\ rem_time >= 8;

int: res_incr_price = 1; % per 1 h of res increase
int: rem_time_decr = 500; % per 1 month of repair of time decrease
int: srok_max_incr = 200; % per 1 month of expl time incr
int: stay_decr = 1000; % per 1 machine staying decrease
int: res_unused = 3; % penalty for unused 1h of op_time

int: n = 15;
set of int: dev = 1..n;
var int: stay;

constraint
stay >= 4 /\ stay <= 10;

array[dev] of int: op_time = [300, 250, 350, 450, 650, 670, 660, 220, 250, 670, 190, 560, 340, 370, 360]; % at the moment when 10 years expire

array[dev] of int: prod_date = [11, 0, 14, 0, 0, 2, 2, 2, 4, 4, 4, 5, 9, 9, 14]; 

array[dev] of var int: rem_date;

array[dev] of var int: return_date;

array[dev] of var int: rem_res;

constraint
forall(i in dev)(rem_date[i] <= srok_max + prod_date[i] /\ rem_date[i] >= srok  + prod_date[i] - 3);

constraint
forall(i in rem_date, j in op_time)((i - srok)*res_incr + j <= res_max);

constraint
forall(i in dev)(return_date[i] = rem_date[i] + rem_time);

constraint
forall(i in dev)(card({rem_date[j] | j in dev where return_date[i] <= rem_date[j]+12})>=stay);

constraint
forall(i in dev)(rem_res[i] = op_time[i] + (rem_date[i] - srok)*res_incr);


array[dev] of var int: res_penalty;

array[dev] of var int: srok_penalty;

var int: stay_penalty;

var int: final_penalty;

var int: rem_time_penalty;

constraint
forall(i in dev)(if rem_date[i] >= 144 then srok_penalty[i] = (rem_date[i]-144)*srok_max_incr else srok_penalty[i] = 0 endif);

constraint
forall(i in dev)(if rem_res[i] >= 750 then res_penalty[i] = (rem_res[i]-res)*res_incr_price else res_penalty[i] = (res - rem_res[i])*res_unused endif);

constraint
if stay < 5 then stay_penalty = (5 - stay)*stay_decr else stay_penalty = 0 endif;

constraint
if rem_time < 12 then rem_time_penalty = rem_time_decr * (12-rem_time) endif;

constraint
final_penalty = sum(i in dev)(srok_penalty[i]+res_penalty[i]);

var int: fin_fin_penal = final_penalty + stay_penalty;

solve :: int_search(rem_date, dom_w_deg, indomain_median)
  minimize fin_fin_penal;

set of int: month = 110..164;

% output [
%   show(fix(fin_fin_penal))] ++ [show(fix(rem_date))] ++ [show(fix(rem_time))] ++ [

%   if j >= fix(rem_date[i]) /\ j <= fix(return_date[i]) then "#" else "|" endif 
%   | i in dev, j in month

% ] ++ ["\n"]

  