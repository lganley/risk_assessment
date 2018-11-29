% objective: create posixtime / epochtime for the beginning of each 8-day
% period from January 1, 2009 through December 31, 2018
%
% author: Dan Pendleton, dpendleton@neaq.org

% set format to avoid scientific notation
format long g 

% create 460 x 6 array to hold dates for 46 8-day periods over 10 years
% array will be structured as [year month day hour minute second]
dat=zeros(46*10,6);

% enter each year 46 times from row 1 - 460
dat(1:46)=2009;
dat(47:92)=2010;
dat(93:138)=2011;
dat(139:184)=2012;
dat(185:230)=2013;
dat(231:276)=2014;
dat(277:322)=2015;
dat(323:368)=2016;
dat(369:414)=2017;
dat(415:460)=2018;

% use convCalendar.m function to convert yearday to month and day for each
% year and yearday 1:8:366

ctr=1; %set counter

for y=2009:2018 %for each year
    
    for d=1:8:365 %for the start day-of-year of each 8-day period within each year
        
        %convert start day-of-year to [month day] and insert into dat
        [dat(ctr,2),dat(ctr,3)]=convCalendar(y,d); 
        
        %update counter
        ctr=ctr+1; 
        
    end
end

% convert dat array to datetime format using datetime.m
t1=datetime(dat(:,1),dat(:,2),dat(:,3),dat(:,4),dat(:,5),dat(:,6));

% convert datetime format to posix format
t2=posixtime(t1);

% calculate the end of the final period, < January 1, 2019
t2end=posixtime(datetime(2019,1,1,0,0,0));

% create array with date immediately before which each 8-day period ends
% i.e. the end-date for period 1 is the start date for period 2
% a "<" operator will be employed so period windows do not overlap
t3=[t2(2:end); t2end];

% create array with [year month day hour minute second posix-time-begin posix-time-end]
period_8d_boundaries = table(dat(:,1), dat(:,2), dat(:,3), dat(:,4), dat(:,5), dat(:,6), t2, t3, 'VariableNames', {'year','month','day','hour','min','sec','start_epochtime','end_epochtime'});

% double check answers at https://www.epochconverter.com/

% write out .csv file
writetable(period_8d_boundaries, 'period_8d_boundaries.csv')