function [A] = MatrixFilter(A)

res = 10;
Rmax = 10;
x = (0:res-1)';
for i = 1:size(A,1)
    for j = 1:res:size(A,2)
        Y = A(i,j:j+res-1)';
        p = polyfit(x,Y,1);
        Ycalc = polyval(p,x);
        R = abs(Y-Ycalc);
        if R(R>Rmax)
           p = polyfit(x(R<Rmax),Y(R<Rmax),1);
           Y(R>Rmax) = polyval(p,x(R>Rmax));
           A(i,j:j+res-1)=Y;
           fprintf('hey got one %d %d\n',i,j);
        end
    end
end

        
        