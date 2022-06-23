% Есть 15 изделий, имеющих срок службы и ресурс до кап. ремонта.
% Дата изготовления изделий различается в пределах года.
% Ремонт длится 1 год.
% Можно превысить срок службы на два года, а ресурс на 200 часов.
% Необходимо распределить даты отправки в ремонт так, чтобы в эксплуатации оставалось 5 (или максимум) единиц.

include "globals.mzn";

%%% Initial data

int: res = 750;
int: srok = 120;

int: res_max = 1000;

int: res_incr = 20; % operation time increment per month

int: n = 15;
set of int: dev = 1..n;

array[dev] of int: op_time = [300, 250, 350, 450, 650, 670, 660, 220, 250, 670, 190, 560, 340, 370, 360]; % at the moment when 10 years expire

array[dev] of int: prod_date = [11, 0, 14, 0, 0, 2, 2, 2, 4, 4, 4, 5, 9, 9, 14]; 

set of int: month = 120..164;


%%% Declare variables

var int: srok_max;

var int: rem_time;

var int: stay;

array[dev] of var int: rem_date;

array[dev] of var int: return_date;

array[dev] of var int: rem_res;

array[dev] of var int: res_penalty;

array[dev] of var int: srok_penalty;

var int: stay_penalty;

var int: final_penalty;

array[dev] of var int: rem_time_penalty;

var int: fin_fin_penal;

array[month] of var int: staying;



%%% Declare weights of change

int: res_incr_price = 1; % per 1 h of res increase
int: rem_time_decr = 2000; % per 1 month of repair of time decrease
int: srok_max_incr = 200; % per 1 month of expl time incr
int: stay_decr = 4000; % per 1 machine staying decrease
int: res_unused = 3; % penalty for unused 1h of op_time



%%% Constraints

constraint
srok_max = 144;

constraint
rem_time = 12;

constraint
stay = 5;

constraint
forall(i in dev)(rem_date[i] <= srok_max + prod_date[i] /\ rem_date[i] >= srok  + prod_date[i] - 3);

constraint
forall(i in rem_date, j in op_time)((i - srok)*res_incr + j <= res_max);

constraint
forall(i in dev)(return_date[i] = rem_date[i] + rem_time);

% constraint
% forall(i in month)(staying[i] = card({j | j in index_set(rem_date) where i < rem_date[j] \/ i > rem_date[j] + rem_time}));

% constraint
% forall(i in month)(staying[i] >= stay);

constraint
forall(i in dev)(rem_res[i] = op_time[i] + (rem_date[i] - srok)*res_incr);

constraint
forall(i in dev)(if rem_date[i] >= prod_date[i] + srok then srok_penalty[i] = (rem_date[i]-prod_date[i] - srok)*srok_max_incr else srok_penalty[i] = 0 endif);

constraint
forall(i in dev)(if rem_res[i] >= 750 then res_penalty[i] = (rem_res[i]-res)*res_incr_price else res_penalty[i] = (res - rem_res[i])*res_unused endif);

% constraint
% if stay < 5 then stay_penalty = (5 - stay)*stay_decr else stay_penalty = 0 endif;

constraint
stay_penalty = card({i | i in month where staying[i] < 5}) * stay_decr;


% constraint
% forall(i in dev)(if rem_time[i] < 12 then rem_time_penalty[i] = rem_time_decr * (12-rem_time[i]) else rem_time_penalty[i] = 0 endif);

constraint
forall(i in dev)(if rem_time < 12 then rem_time_penalty[i] = (12 - rem_time)*rem_time_decr else rem_time_penalty[i] = 0 endif);

constraint
final_penalty = sum(i in dev)(srok_penalty[i]+res_penalty[i]+rem_time_penalty[i]);


constraint
fin_fin_penal = final_penalty + stay_penalty;



%%% Solve

solve
%   :: warm_start_array( [                     %%% Can be on the upper level
%      warm_start( rem_date, [132,120,133,120,120,122,122,122,129,128,136,129,131,131,133] ),               %%% Use <> for missing values
%      warm_start( rem_time, [8,8,8,8,8,8,8,8,8,8,8,8,8,8,8] ),
% %      warm_start( stay, 3 ),
%                         ])
%    :: int_search(rem_date, dom_w_deg, indomain_median)
%     minimize fin_fin_penal;
satisfy;


%%% Output config 

% output [
%   show(fix(fin_fin_penal))] ++ [show(fix(rem_date))] ++ [show(fix(rem_time))] ++ [

%   if j >= fix(rem_date[i]) /\ j <= fix(return_date[i]) then "#" else "|" endif 
%   | i in dev, j in month

% ] ++ ["\n"]

  