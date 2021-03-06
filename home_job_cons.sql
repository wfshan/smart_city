create table home_job_cons as 
select province,city, date, 
case when homeid is not null then homeid else -1 end as homeid, 
case when jobid is not null then jobid else -1 end as jobid, 
case when consumeid is not null then consumeid else -1 end as consumeid, 
count(1) as n_num, cast(round(sum(weight)) as bigint) as w_num from(
select a.province, a.city, a.date, a.uid, homeid, jobid, consumeid, weight from (
select province,city, date, uid from openlab.stay_poi where date = 20170901 and city = 'V0110000' group by province,city, date, uid
)a left outer join(
select province, city, date, uid, final_grid_id as homeid
from openlab.stay_poi
where date = 20170901 and city = 'V0110000' and ptype = 1 
)b on(a.uid = b.uid and a.province = b.province and a.city = b.city and a.date = b.date)
left outer join (
select province, city, date, uid, final_grid_id as jobid
from openlab.stay_poi
where date = 20170901 and city = 'V0110000' and ptype = 2 
)c on(a.uid = c.uid and a.province = c.province and a.city = c.city and a.date = c.date) 
left outer join (
select province, city, date, uid, consumeid from (
select province, city, date, uid, final_grid_id as consumeid, row_number() over(partition by uid order by weekend_day_time desc)as time_rank
from openlab.stay_poi 
where date = 20170901 and city = 'V0110000' and ptype = 0 and weekend_day_time >= 7200
)a where time_rank = 1 
)d on(a.uid = d.uid and a.province = d.province and a.city = d.city and a.date = d.date)
inner join(
select province, city, date, uid,weight from openlab.user_attribute where date = 20170901 and city = 'V0110000' 
)e on(a.uid = e.uid and a.province = e.province and e.city = e.city and e.date = e.date)
)a group by province, city, date, case when homeid is not null then homeid else -1 end, 
case when jobid is not null then jobid else -1 end, 
case when consumeid is not null then consumeid else -1 end;
