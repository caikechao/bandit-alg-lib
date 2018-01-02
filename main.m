%% read the parameters of the arms
clc
close all
clear
ad_click = load('x-ad-click.csv');

%% construct arms, arm names
arm_para = ad_click;
% set of arms
arms = [];
% names of the arms
arm_names = {};
for i = 1:length(arm_para)
    arms = [arms, L2Arm(arm_para(i, 1), arm_para(i, 2))];
    arm_names = [arm_names, {arms(i).getArmInfo()}];
end
% rng(0)
%% construct policies
K = length(arms);
L = 30; % number of arms are pulled at each round. 10, 2.5, 20, 10,
T = 30000; % number of rounds.
h = 20; % threshold
% optimal policy and optimal reward
[optx, optr] = calculate_opt(arm_para, L, h);
% pause
% set of policies
policies = {};
% names of polices
policy_names = {};
% put policies into the set.
%% UCB
% parameters of UCB
policies = [policies, {Policy_UCB(K, L, 1.5, 2)}];
%% EXP3M
% % parameters of EXP3M
exp3m_gamma = min(1, sqrt(K*log(K/L)/((exp(1) - 1) * L * T)));
policies = [policies, {Policy_EXP3M(K, L, exp3m_gamma, 2)}];
%% LExp
% % parameters of LExp
lexp_gamma = min(1, 2*sqrt((2 * (exp(1) - 2) * K + K * L)/(L * log(K/L) * T^(2 / 3)))/L);
lexp_delta = 4 * (exp(1) - 2) * lexp_gamma * L / (1 - lexp_gamma);
% % lexp_gamma = 0.02;
% % lexp_delta = 0.02;
policies = [policies, {Policy_LExp(K, L, lexp_gamma, lexp_delta, h)}];

P = length(policies);

%% Simulation
simulator = MbanditSimulator(arms, policies, K, L, h);
logger = RoundwiseLog(P, K, T);
simulator.run_simulation(T, logger); % T rounds of simulation
sim_log = LogWriter(logger, L, h, arm_para, optr, arm_names, policy_names);
sim_log.dump('test-edx-course.txt')

