function [month,day]=convCalendar(year,jday);

%[month,day]=convCalendar(year,jday);
%
%input: column vectors containing year and julian day
%output: column vectors containing month and day corresponding to rows in
%input vector of year and julian day

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
n=length(jday);
if m~=n
    error('jday and year must be column vectors of the same length')
end

%defining month/day combo, and julian days for a nonleap year
jda=(1:365)';
mo=[ones(31,1);2*ones(28,1);3*ones(31,1);4*ones(30,1);5*ones(31,1);6*ones(30,1);7*ones(31,1);8*ones(31,1);9*ones(30,1);10*ones(31,1);11*ones(30,1);12*ones(31,1)];
da=[(1:31)';(1:28)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)'];
    
%for leap year...
jdal=(1:366)';
mol=[ones(31,1);2*ones(29,1);3*ones(31,1);4*ones(30,1);5*ones(31,1);6*ones(30,1);7*ones(31,1);8*ones(31,1);9*ones(30,1);10*ones(31,1);11*ones(30,1);12*ones(31,1)];
dal=[(1:31)';(1:29)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)';(1:31)';(1:30)';(1:31)';(1:30)';(1:31)'];

%generate list of 0 and 1 to tell if year is leap or nonleap

for i=1:m
    ly(i)=(rem(year(i),4)==0);
end
ly=double(ly);

for i=1:m
    if ly(i)==0 %not in a leap year
        jday_i=jday(i);
        I=find(jda==jday_i);
        if isempty(I) | length(I)>1
            error('nonleap year: some kind of problem with the month day setup in the code')
        end
        month(i)=mo(I);
        day(i)=da(I);
    elseif ly(i)==1 %in a leap year
        jday_i=jday(i);
        I=find(jdal==jday_i);
        if isempty(I) | length(I)>1
            error('leap year: some kind of problem with the month day setup in the code')
        end
        month(i)=mol(I);
        day(i)=dal(I);
    end 
end
month=month';
day=day';