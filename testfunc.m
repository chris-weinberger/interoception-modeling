function testfunc
x = 1;
y = zeros(1,16);

test2();
disp(x);
disp(y)
    function test2
        x = x+1;
        y(3) = 4;
    end
end