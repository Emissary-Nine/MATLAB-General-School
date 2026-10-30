tic  %start timer
a=0;  %initialize a to zero
for inda=1:5000000  %loop five million times
    a=a+randi(300,1);  %generate a random number and keep a running sum
end
sprintf('%15.4f',a)  %display the final value
toc %display how long it took to run
