var int: gamma;
var int: beta;
var int: phi;

float: pi = 3.141592653589793238462643383279502884197;
% float: blade_Rcm = 167.89;
% float: blade_vol = 3394.4957;
% float: mat_density = 8760;
% float: n = 19200;
% float: l_d = 8.15;
% float: sigma_sm_dop =  230;
% float: sigma_iz_dop = 200;
% float: tau_sr_dop = 120;
% float: b = 30;
% int: z = 3;

function var float: gamma_rad(var int: gamma) = gamma * pi / 180;
function var float: beta_rad(var int: beta) = beta * pi / 180;
function var float: phi_rad(var int: phi) = phi * pi / 180;
function var float: psi_rad(var float: beta_rad, var float: phi_rad) = beta_rad - (1.5708 - phi_rad/2);


function var float: m1(var float: gamma_rad, var float: beta_rad, var float: psi_rad) = (2 * sin(beta_rad - gamma_rad) / sin(gamma_rad) - 0.7 * tan(1 / (gamma_rad / 2)) - 0.05 / cos(psi_rad))*cos(psi_rad);
function var float: m3(var float: gamma_rad, var float: beta_rad, var float: phi_rad, var float: psi_rad) = (2 * sin(beta_rad - gamma_rad) / sin(gamma_rad) - 0.35 * tan(1 / (gamma_rad / 2)) - 0.05 / cos(psi_rad))*sin(gamma_rad) / sin(beta_rad - gamma_rad + phi_rad / 2);
function var float: m4(var float: gamma_rad, var float: beta_rad, var float: phi_rad) = (2 * sin(beta_rad - gamma_rad) / sin(gamma_rad) - 0.35 * tan(1 / (gamma_rad / 2)) + 0.35 * tan(1 / (beta_rad / 2))) * sin(gamma_rad) / sin(beta_rad - gamma_rad);
function var float: m5(var float: gamma_rad, var float: beta_rad, var float: phi_rad, var float: psi_rad, var float: m4, var float: m1) = m1 / 2 / cos(psi_rad) + 0.35 * tan(1 / (beta_rad / 2)) - m4 / 2 * sin(beta_rad - 1.5708) + 0.05 / cos(psi_rad);


var float: K_sm = 1/m1(gamma_rad(gamma), beta_rad(beta), psi_rad(beta_rad(beta), phi_rad(phi)));
var float: K_iz = 6 * m5(gamma_rad(gamma), beta_rad(beta), phi_rad(phi), psi_rad(beta_rad(beta), phi_rad(phi)), m4(gamma_rad(gamma), beta_rad(beta), phi_rad(beta)), m1(gamma_rad(gamma), beta_rad(beta), psi_rad(beta_rad(beta), phi_rad(phi)))) / m4(gamma_rad(gamma), beta_rad(beta), phi_rad(beta))^2 / cos(psi_rad(beta_rad(beta),phi_rad(phi)));
var float: K_sr = 1/m3(gamma_rad(gamma), beta_rad(beta), phi_rad(phi), psi_rad(beta_rad(beta), phi_rad(phi)));


% var float: m1 = 2 * beta_rad;
% var float: m3 = 15/(gamma_rad);
% var float: m4 = 2* (phi_rad);
% var float: m5 = m1 / m3 * m4;



constraint
gamma_rad(gamma) > 0.9599 /\ gamma_rad(gamma) < 1.1345;

constraint
beta_rad(beta) > 1.8326 /\ beta_rad(beta) < 2.0944;

constraint
phi_rad(phi) > 0.5236 /\ phi_rad(phi) < 0.8727;

constraint
K_sm < 1;

constraint
K_sr < 1;

constraint
K_iz < 1;


solve satisfy;

