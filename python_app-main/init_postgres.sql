create table AED_history_data(
id SERIAL PRIMARY KEY,
date TIMESTAMP,
value float);

insert into public.aed_history_data(date, value) values('2010-01-01 00:00:00', 7.6);
insert into public.aed_history_data(date, value) values('2011-01-01 00:00:00', 8.6);
insert into public.aed_history_data(date, value) values('2012-01-01 00:00:00', 8.7);
insert into public.aed_history_data(date, value) values('2013-01-01 00:00:00', 9.2);
