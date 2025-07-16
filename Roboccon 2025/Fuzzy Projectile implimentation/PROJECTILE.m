% Projectile motion code
t=0:0.03:5; % time vector
u=10; %initial velocity
angle=15;
theta = unitsratio('rad','deg')*angle;
g=9.81;


ux = u*cos(theta);
uy = u*sin(theta);
x=ux*t; % range
y = uy*t-0.5*g*t.^2;

for i=1:size(x,2)
    if(i>1 && y(i)<=0)
        %break;
    end
    plot(x(i),y(i),'r*');
    xlabel('x(i)');
    ylabel('y(i)')
    hold on; % comment if you don't want to see the whole path
    pause(0.03);
end


