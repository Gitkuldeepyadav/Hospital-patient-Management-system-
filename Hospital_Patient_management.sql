-- Sql Project (Healthcare Management System) 

create database mysql_db
use mysql_db

select * from patients 

1.	Retrieve the complete list of all patients.
select * from patients

2.	Retrieve the complete list of all doctors.
select * from doctors 

3.	Display all the departments available in the hospital.
select distinct department_name from departments

4.	Fetch all appointments that have been marked as 'Completed'.
select * from appointments where status ='Completed'

5.	Find all patients whose age is greater than 40 years.
select * from patients where age>40

6.	Count the total number of doctors in the hospital.
select count(doctor_id) from doctors

7.	Retrieve all patients whose gender is 'Male'.
select * from patients where gender='Male'

8.	Fetch all appointments scheduled on the date '2024-11-01'.
select * from appointments where appointment_date='2024-11-01'

9.	List all diagnosis records available in the system.
select * from diagnosis

10.	Retrieve all bills where the payment status is 'Unpaid'.
select * from billing where payment_status='Unpaid'

explain select * from appointments where patient_id=201


select * from diagnosis

11.	Count the number of patients grouped by gender.
select gender,count(patient_id) from patients group by gender 

12.	Find the total number of appointments handled by each doctor.
select d.doctor_id,d.doctor_name ,count(a.appointment_id) from doctors d
left join appointments a  on d.doctor_id=a.doctor_id
group by d.doctor_name,d.doctor_id
select * from doctors 
select * from appointments
select * from billing

13.	Calculate the total revenue collected from all patients.
select sum(paid_amount) as Total_revenue from billing

14.	Determine the treatment duration (in days) for every patient.
select p.patient_name,datediff(t.treatment_end,t.treatment_start) as trtment_days
from treatments t 
join billing b on t.treatment_id=b.treatment_id
join patients p on b.patient_id=p.patient_id


15.	Calculate the total billing amount generated per patient.
select p.patient_name,b.total_amount from billing b
join patients p on b.patient_id=p.patient_id 

select p.patient_name,
sum(b.Total_amount) over(partition by p.patient_name) as total
from billing b 
join patients p on b.patient_id=p.patient_id  

16.	Display doctor names along with the departments they belong to.
select d.doctor_name, dept.department_name from doctors d
join departments dept on d.department_id=dept.department_id

select d.doctor_name, dept.department_name from doctors d
left join departments dept on d.department_id=dept.department_id
where dept.department_id is null

17.	Fetch all appointments along with the respective patient and doctor names.
select p.patient_name,d.doctor_name,a.appointment_id,a.appointment_date from appointments a
join patients p on a.patient_id=p.patient_id
join doctors d on a.doctor_id=d.doctor_id

18.	List all patients along with their medical diagnosis details.
select p.patient_name,dia.diagnosis_desc from patients p 
join appointments a on p.patient_id=a.patient_id
join diagnosis dia on  a.appointment_id=dia.appointment_id

19.	Calculate the total number of patients treated in each department.
select d.department_name,count(p.patient_id) as cnt_patient from departments d
join doctors doc on d.department_id=doc.department_id
join appointments a on  doc.doctor_id=a.doctor_id
join patients p on a.patient_id=p.patient_id
group by d.department_name

20.	Determine the average cost of all treatments administered.
select t.treatment_id, avg(b.total_amount) from treatments t
join billing b on t.treatment_id=b.treatment_id
group by t.treatment_id

select * from treatments
21.	Retrieve the complete journey of each patient from appointment to billing.
select p.patient_name,p.age,a.appointment_date,a.appointment_time,d.doctor_name,dep.department_name,dia.diagnosis_desc,
t.treatment_desc,t.treatment_start,b.total_amount,b.paid_amount 
from patients p 
join appointments a on p.patient_id=a.patient_id
join doctors d on a.doctor_id=d.doctor_id 
join departments dep on d.department_id=dep.department_id 
join diagnosis dia on a.appointment_id=dia.appointment_id
join treatments t on dia.diagnosis_id =t.diagnosis_id
join billing b on t.treatment_id=b.treatment_id 

Join all tables 

22.	Find the average treatment duration for each department.
select dep.department_name,round(avg(datediff(t.treatment_end,t.treatment_start)),2) from treatments t
join billing b on t.treatment_id=b.treatment_id 
join appointments a on b.patient_id=a.patient_id
join doctors d on a.doctor_id=d.doctor_id
join departments dep on d.department_id=dep.department_id
group by dep.department_name

23.	Rank doctors based on the number of appointments they have handled.
select d.doctor_name, count(a.appointment_id),
dense_rank() over(order by count(a.appointment_id) desc) as rnk_doctors
from doctors d
left join appointments a on d.doctor_id=a.doctor_id 
group by d.doctor_name

24.	Identify the patients who have spent the highest total amount on treatment.
select patient_name from patients 
where patient_id in (select * from (
select patient_id from billing 
order by total_amount desc 
limit 1) as dummy)

with base as (select p.patient_name , sum(b.total_amount) as Total,
dense_rank() over(order by  sum(b.total_amount) desc) as rnk_no
from patients p 
join billing b on p.patient_id=b.patient_id
group by p.patient_name)
select patient_name,Total from base 
where rnk_no=1

25.	Find the patient who had the longest treatment duration.
with base as (select p.patient_name , datediff(t.treatment_end,t.treatment_start) as duration,
dense_rank() over(order by datediff(t.treatment_end,t.treatment_start) desc) as rnk_no
from treatments t 
join billing b on t.treatment_id=b.treatment_id
join patients p on b.patient_id=p.patient_id
)
select patient_name ,duration from base 
where rnk_no=1

26.	Identify the doctor who generated the highest treatment revenue.
with base as (select d.doctor_name , sum(b.total_amount) as Total_amount,
dense_rank() over (order by sum(b.total_amount)  desc) as rnk
from billing b
join appointments a on b.patient_id=a.patient_id
join doctors d on a.doctor_id=d.doctor_id
group by d.doctor_name)
select doctor_name, Total_amount from base 
where rnk=1

27.	Determine the most frequently occurring diagnosis.
with base as (select t.diagnosis_id,dia.diagnosis_desc,count(t.diagnosis_id) as cnt,
dense_rank() over (order by count(t.diagnosis_id) desc) as rnk
from diagnosis dia 
join treatments t on dia.diagnosis_id=t.diagnosis_id
group by dia.diagnosis_desc,t.diagnosis_id)
select diagnosis_id,diagnosis_desc,cnt from base 
where rnk =1

select * from treatments

28.	List all patients who still have pending dues.
select p.patient_name from patients p
join billing b on p.patient_id=b.patient_id
where b.payment_status='Pending'

29.	Find the patient who has booked the maximum number of appointments.
with base as (select p.patient_name, count(a.appointment_id) as cnt,
dense_rank() over(order by count(a.appointment_id) desc) as rnk
from appointments a 
join patients p on a.patient_id=p.patient_id
group by p.patient_name)
select patient_name,cnt from base 
where rnk=1

30.	Generate the daily revenue report based on payment records
select a.appointment_date,sum(b.paid_amount) as Total_revenue from appointments a 
join billing b on a.patient_id=b.patient_id
group by a.appointment_date


