
clear
clc

a = 0;
b = 2;

fprime = @(x) exp(x) - 3;

x = linspace(0,2,200);

figure

subplot(2,1,1)
plot(x,fprime(x),'b','LineWidth',1.5)
hold on
yline(0,'k')
grid on
title("Derivative f'(x)")
xlabel('x')
ylabel("f'(x)")

subplot(2,1,2)
hold on
grid on
xlim([0 2])
ylim([0 6])
title('Bracket after each iteration')
xlabel('x')
ylabel('Iteration')

iteration = 0;

while b-a >= 0.1
    m = (a+b)/2;
    iteration = iteration+1;

    subplot(2,1,1)
    xline(m,'r--')

    if fprime(m) < 0
        a = m;
    else
        b = m;
    end

    subplot(2,1,2)
    plot([a b],[iteration iteration], ...
         'b-','LineWidth',3)

    fprintf('Iteration %d: [%.4f, %.4f]\n', ...
            iteration,a,b)
end

midpoint = (a+b)/2;
fprintf('Final midpoint = %.4f\n',midpoint)
