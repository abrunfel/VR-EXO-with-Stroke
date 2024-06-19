clear all; close all
% Creates a 100x54 matrix consisting of pseudorandomly generated integers
% 6 and 7, without repeats, and with an even distribution across
% all numbers. NOTE: these numbers are used in C#, which is zero-indexed,
% so integers 6,7 correspond to target locations 7,8. See lab book pages
% 45-47, and 121 (for an update).

numTrials = 54; % desired number of trials (must be multiple of 6)
orders = zeros(100,numTrials);
for i = 1:(numTrials/2)
    for j = 1:100
        orders(j,2*i-1:2*i) = randperm(2,2)+5;
    end
end

% Double check this!
histogram(orders(1,:))
writematrix(orders, 'RandomOrders_7&8_54.txt', 'delimiter','\t');

% % Random ints from 0-13
% orders100 = randi([0,13],100);
% % Double check this!
% histogram(orders100(1,:))
% writematrix(orders100, 'RandomOrders_5to10_100.txt', 'delimiter','\t');