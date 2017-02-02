WITH AOL AS 
(Select A.Employee_id as"Employee Id",A.Absence_plan ,A.End_bal ,(A.End_bal-A.Accrued-A.used) as "Carry Over"
,A.used as "Leave Taken",A.Accrued as "Yearly Accrual" ,B.FULL_NAME 

			,(SELECT USER_STATUS
            FROM PER_ASSIGNMENT_STATUS_TYPES_TL
	       WHERE ASSIGNMENT_STATUS_TYPE_ID = PAAM.ASSIGNMENT_STATUS_TYPE_ID
	         AND LANGUAGE = 'US'
		     AND ROWNUM = 1
	   	) ASSIGNMENT_STATUS_CODE

FROM per_all_assignments_m paam,
(Select (Select name from ANC_ABSENCE_PLANS_F_TL ap where ap.absence_plan_id=pa.Plan_id and trunc(sysdate)
 between effective_start_date and effective_end_date and language='US') Absence_plan,
 (Select pf.Person_number
 from per_all_people_f pf where pf.Person_id=PA.person_id and 
 trunc(sysdate) between effective_start_date and Effective_end_date) Employee_id, End_bal,person_id,Accrued,used 
 ,PER_ACCRUAL_ENTRY_ID
 from ANC_PER_ACCRUAL_ENTRIES PA 
where PER_ACCRUAL_ENTRY_ID in ( Select  max(PER_ACCRUAL_ENTRY_ID) from ANC_PER_ACCRUAL_ENTRIES Pb where to_char(trunc( Accrual_period),'YYYY')= to_char(trunc(sysdate),'YYYY') group by Plan_id,person_id   )) A ,PER_PERSON_NAMES_F B
Where A.person_id=B.Person_id
AND A.person_id = paam.person_id
AND TRUNC(SYSDATE) Between B.Effective_start_date and B.Effective_end_date
AND TRUNC(SYSDATE) Between paam.Effective_start_date and paam.Effective_end_date --sherwin 24-jun-2016, exclude terminated employees
and paam.PRIMARY_FLAG = 'Y' --sherwin 24-jun-2016, exclude terminated employees
AND name_type='GLOBAL'
AND A.Absence_plan in(:Leave_Plan)
)

SELECT *
FROM AOL
WHERE AOL.ASSIGNMENT_STATUS_CODE = 'Active - Payroll Eligible'