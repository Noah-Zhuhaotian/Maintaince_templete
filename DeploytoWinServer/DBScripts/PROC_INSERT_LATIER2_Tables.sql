
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PWSYS"."PROC_INSERT_LATIER2_TABLES" 
(v_year VARCHAR2, v_site VARCHAR2, v_hzdlist_name VARCHAR2, v_hzdreport_threshold NUMBER, v_exhzdlist_name VARCHAR2, v_exhzdreport_threshold NUMBER,is_chemical_category VARCHAR2 )
IS
   error_msg   VARCHAR2 (512);
   error_num   NUMBER (10);
BEGIN
   PROC_INSERT_LATIER2_INV_H(v_year,v_site,v_hzdlist_name,v_hzdreport_threshold);
   PROC_INSERT_LATIER2_INV_E(v_YEAR,v_site,v_exhzdlist_name,v_exhzdreport_threshold);
   DELETE FROM PWSYS.INTERM_LATIER2_INV  WHERE rowid NOT IN (SELECT max(rowid) FROM PWSYS.INTERM_LATIER2_INV GROUP BY VLD_SITE_ID, IDEN_NUM, MAT_ID, MAX_AMT, AVG_AMT, DAY_YR_ON_SITE HAVING count(*)>=1) ;
   proc_insert_latier2_loc(v_year,v_site,is_chemical_category);
   proc_insert_latier2_mat(is_chemical_category,v_exhzdlist_name);
   proc_insert_latier2_comp_sub(is_chemical_category);
   proc_insert_latier2_comp_main(is_chemical_category,v_exhzdlist_name,v_year);
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      error_num := SQLCODE;
      error_msg := SQLERRM;
      DBMS_OUTPUT.put_line ('ERROR CODE: ' || error_num || ' -- ERROR Message: ' || error_msg);
      DBMS_OUTPUT.put_line (TO_CHAR (SYSDATE, 'DD-MON-YY HH24:MI:SS') || ' Program completion status: FAIL');
END;
/