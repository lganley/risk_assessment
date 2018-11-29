function [jday]=convJulian(year,month,day);

%[jday]=convJulian(year,month,day);
%
%input: column vectors containing month and corresponding day
%output column vector of julian days corresponding to rows of month and day
%************************FOR REFERENCE************************************
%NONLEAP YEAR
%month
%   1       2       3       4       5       6       7       8       9       10      11      12
%begins on jday
%   1       32      60      91      121     152     182     213     244     274     305     335  
    
%LEAP YEAR
%month
%   1       2       3       4       5       6       7       8       9       10      11      12
%begins on jday
%   1       32      61      92      122     153     183     214     245     275     306     336  
%*************************************************************************

m=length(year);
n=length(month);
p=length(day);
if m~=n & m~=p & p~=n
    error('month, day and year must be column vectors of the same length')
end

  %defining month/day combo, and julian days for a nonleap year
jda=(1:365)';
mo=[ones(31,1);2*ones(28,1);3*ones(31,1);4*ones(30,1);5*ones(31,1);6*ones(30,1);7*ones(31,1);8*ones(31,1);9*ones(30,1);10*ones(31,1);11*ones(30,1);12*ones(31,1)];
da=[(1:31)';(1:28)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)'];
    
%for leap year...
jdal=(1:366)';
mol=[ones(31,1);2*ones(29,1);3*ones(31,1);4*ones(30,1);5*ones(31,1);6*ones(30,1);7*ones(31,1);8*ones(31,1);9*ones(30,1);10*ones(31,1);11*ones(30,1);12*ones(31,1)];
dal=[(1:31)';(1:29)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)'];

% %get years
% Ys=min(year):max(year);
% %find leap and nonleap years
% leapcheck=(rem(Ys,4)==0); leapcheck=double(leapcheck);

%generate list of 0 and 1 to tell if year is leap or nonleap
for i=1:length(year)
    ly(i)=(rem(year(i),4)==0);
end
ly=double(ly);
for i=1:length(month)
    if ly(i)==0 %not in a leap year
        month_i=month(i);
        day_i=day(i);
        I=find(mo==month_i & da==day_i);
        if isempty(I) | length(I)>1
            error('nonleap year: some kind of problem with the month day setup in the code')
        end
        jday(i)=jda(I);
    elseif ly(i)==1 %in a leap year
        month_i=month(i);
        day_i=day(i);
        I=find(mol==month_i & dal==day_i);
        if isempty(I) | length(I)>1
            error('leap year: some kind of problem with the month day setup in the code')
        end
        jday(i)=jdal(I);        
    end 
end
jday=jday';
