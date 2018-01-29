%% read the parameters of the arms
close all
clear
%% Add the paths of the classes
addpath(genpath('Arm'))
addpath(genpath('Policy'))
addpath(genpath('SimLog'))
addpath(genpath('Utils'))
%% load the data
ad_click = load('data/x-ad-click.csv');
% coupon_purchase = load('data/x-coupon-data.csv');
% edx_course = load('data/x-edx-course.csv');
% channel_info = load('data/x-channel.csv');
%% construct arms, arm names
arm_para = ad_click;
% set of arms
arms = [];
% names of the arms
arms_info = {};
for i = 1:length(arm_para)
    arms = [arms, L2Arm(arm_para(i, 1), arm_para(i, 2))];
    arms_info = [arms_info, {arms(i).getArmInfo()}];
end
% rng(0)
%% construct policies
K = length(arms);
L = 20; % number of arms are pulled at each round. 10, 2.5, 20, 10,
T = 100000; % number of rounds.
h = 12; % threshold
% optimal policy and optimal reward
[optx, optr] = calculateOracleOpt(arm_para, L, h);
% pause
% set of policies
policies = {};
% names of polices
policies_info = {};
% put policies into the set.
%% UCB
% parameters of UCB
ucb_alpha = 1.5;
policies = [policies, {PolicyUCB(K, L, ucb_alpha, 2)}];
%% EXP3M
% parameters of EXP3M
exp3m_gamma = min(1, sqrt(K*log(K/L)/((exp(1) - 1) * L * T)));
policies = [policies, {PolicyEXP3M(K, L, exp3m_gamma, 2)}];
%% LExp
% parameters of LExp
% lexp_gamma = min(1, 2*sqrt((2 * (exp(1) - 2) * K + K * L)/(L * log(K/L) * T^(2 / 3)))/L);
% lexp_delta = 4 * (exp(1) - 2) * lexp_gamma * L / (1 - lexp_gamma);
lexp_gamma = 0.03;
lexp_delta = 0.03;
policies = [policies, {PolicyLExp(K, L, lexp_gamma, lexp_delta, h)}];
%% Name of policies
for i = 1:length(policies)
    policies_info = [policies_info, {policies{i}.getPolicyInfo()}];
end
P = length(policies);
%% Simulation
% simulation is timevarying or not; 
timevaryingp = false;
% number of running times
nSimulations =  1;
simulator = MbanditSimulator(arms, ...
                             policies, ...
                             K, L, h, ...
                             timevaryingp, ...
                             nSimulations);
logger = RoundwiseLogger(policies, nSimulations, K, T);
simulator.run_simulation(T, logger);
sim_log = LogWriter(logger, L, h, arm_para, optr, policies_info);
sim_log.dump('out/adclick_result.txt')
