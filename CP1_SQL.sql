create schema cp1;

use cp1;

select `Customer ID` , count(*) as ct from cp1.hospitalisation_details
group by `Customer ID`
order by ct desc;

SET SQL_SAFE_UPDATES = 0;

delete from cp1.hospitalisation_details
where `Customer ID` ="?";

# making cust id not null
alter table cp1.hospitalisation_details
modify  `Customer ID` varchar(10) not null;

# making it a primary key
alter table cp1.hospitalisation_details
add primary key ( `Customer ID`);

# repeating with medic table
alter table cp1.medical_examinations
modify  `Customer ID` varchar(10) not null;

desc cp1.hospitalisation_details;

desc cp1.medical_examinations;

SET SQL_SAFE_UPDATES = 1;

select `Customer ID` , count(*) as ct from cp1.hospitalisation_details
group by `Customer ID`
order by ct desc;

/* 2. Get information about individuals who are diabetic and have heart ailments. 
      Get average age, average no. of children dependent, average BMI, and 
      average hospitalization costs for such individuals. */
 
 SELECT 
    m.diabetes,
    m.`Heart Issues`,
    round(AVG(h.age),0) AS avg_age,
    round(AVG(h.children),0) AS avg_child_dep,
    round(AVG(m.BMI),2) AS avg_bmi,
    round(AVG(h.charges),2) AS avg_charges
FROM
    (select * , 2022 - year AS age
    from cp1.hospitalisation_details) h,
    (SELECT 
        *,
            CASE
                WHEN HBA1C > 6.5 THEN 'Yes'
                ELSE 'No'
            END AS diabetes
    FROM
        cp1.medical_examinations) m
	where h.`Customer ID` = m.`Customer ID`
GROUP BY m.diabetes ,m.`Heart Issues`;


/* What are the average charges of hospitalization across different hospital levels and cities?*/
/* replace "?" in City tier and hospital tier with mode value */

select `Hospital tier`,count(*) as ct
from cp1.hospitalisation_details
group by `Hospital tier`
order by ct ;

select `City tier`,count(*) as ct
from cp1.hospitalisation_details
group by `City tier`
order by ct ;

# replace "?" with mode values
SET SQL_SAFE_UPDATES = 0;
update cp1.hospitalisation_details
set `Hospital tier` = "tier - 2"
where `Hospital tier` = "?";

update cp1.hospitalisation_details
set `City tier` = "tier - 2"
where `City tier` = "?";
SET SQL_SAFE_UPDATES = 1;

select `Hospital tier`, `City tier` , avg(charges) as avg_charges
from  cp1.hospitalisation_details
group by `Hospital tier`,`City tier`;


/* How many individuals who have had any major surgeries have cancer history? */
select `Cancer history`, surgery, count(*) as count_pat
from (
select *, 
case 
when NumberOfMajorSurgeries>= 1 then "Yes"
else "No"
end as surgery
from  cp1.medical_examinations) m
group by `Cancer history`, surgery
having `Cancer history` = "yes"
;

/* Find out how many Tier-1 hospitals in each state.*/

# replace "?" in state id with mode value
select * from cp1.hospitalisation_details ;
select `State ID` , count(*) as ct
from cp1.hospitalisation_details
group by `State ID`
order by ct desc;
SET SQL_SAFE_UPDATES = 0;
update cp1.hospitalisation_details
set `Hospital tier` = "tier - 2"
where `Hospital tier` = "?";

select `State ID`, `Hospital tier` , count(*) as hosp_count
from cp1.hospitalisation_details
group by `State ID`, `Hospital tier`
having `Hospital tier` = "tier - 1";
