/*
SQLyog Ultimate v12.08 (64 bit)
MySQL - 5.7.29 : Database - inss_mes
*********************************************************************
*/


/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`inss_mes` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `inss_mes`;

/* Function  structure for function  `fn_tb_costloss` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) as count from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_all`( in_fr_dt date, in_to_dt date,check_type int,dept_name varchar(50)) RETURNS varchar(1024) CHARSET latin1
Begin

  Declare out_x VARCHAR(1024) default "";

  Declare test_txt_len int default 0;

  Declare test_txt VARCHAR(1024) default "";

  Declare xx VARCHAR(1024) default "";

  Declare yy VARCHAR(1024) default "";

	Declare rate VARCHAR(1024) default "";

	Declare res_diff int default 0;

	Declare isMth TINYINT(1) default 0;

	Declare isDay TINYINT(1) default 0;

	

	if timestampdiff(month,in_fr_dt,in_to_dt) >0 then 

		set isMth = 1;

	elseif timestampdiff(day,in_fr_dt,in_to_dt) >0 then 

		set isDay = 1;

	end if;

	

	if dept_name="ALL" then

		set res_diff = 1; /* deptname_all */

	else 

		set res_diff = 2; /* deptname */

	end if;



	if check_type =1 then

			if dept_name="ALL" then

				Select fn_tb_costloss_for_deptname_all(in_fr_dt,in_to_dt) into test_txt;

			else

				Select fn_tb_costloss_for_deptname(in_fr_dt,in_to_dt,dept_name) into test_txt;

			end if;

		Select length(test_txt) into test_txt_len;

	elseif check_type >3 and check_type < 7 then

		Select fn_tb_costloss(in_fr_dt, in_to_dt) into test_txt;

		Select length(test_txt) into test_txt_len;

		if isMth=1 and res_diff=1 then 

			Select fn_tb_costloss_mth_concat_x_deptname_all(in_fr_dt,in_to_dt) into xx;

			Select fn_tb_costloss_mth_concat_y_deptname_all(in_fr_dt,in_to_dt) into yy;

		elseif isMth=1 and res_diff=2 then

			Select fn_tb_costloss_mth_concat_x_deptname(in_fr_dt,in_to_dt,dept_name) into xx;

			Select fn_tb_costloss_mth_concat_y_deptname(in_fr_dt,in_to_dt,dept_name) into yy;

		elseif isDay=1 and res_diff=1 then

			Select fn_tb_costloss_day_concat_x_deptname_all(in_fr_dt,in_to_dt) into xx;

			Select fn_tb_costloss_day_concat_y_deptname_all(in_fr_dt,in_to_dt) into yy;

		elseif isDay=1 and res_diff=2 then

			Select fn_tb_costloss_day_concat_x_deptname(in_fr_dt,in_to_dt,dept_name) into xx;

			Select fn_tb_costloss_day_concat_y_deptname(in_fr_dt,in_to_dt,dept_name) into yy;

		end if;

	end if;

	

  if test_txt_len < 2 then

     set out_x = '{"data":null,"code":1}';

  else

		if check_type = 1 then

			set out_x = concat( '{"data":{"deptvalue":[', test_txt, ']},"code":1}');

		elseif check_type>3 and check_type<7 then		

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');

	  elseif check_type=7 then 

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"xAxisData2":[',xx,'],"deptvalue":{"reason":[', test_txt, '],"rate":[',rate,']}},"code":1}');

		end if;

		

   end if;

   return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_day_concat_x_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_day_concat_x_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_day_concat_x_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct occur_date from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt and dept_name=in_dept_name group by occur_date,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_day_concat_x_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_day_concat_x_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_day_concat_x_deptname_all`( in_fr_dt date, in_to_dt date  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct occur_date from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt group by occur_date,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_day_concat_y_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_day_concat_y_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_day_concat_y_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt and dept_name=in_dept_name group by dept_name,occur_date  asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_day_concat_y_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_day_concat_y_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_day_concat_y_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt group by dept_name,occur_date asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_for_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_for_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_for_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) as count from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt and dept_name=in_dept_name group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_for_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_for_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_for_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) as count from VW_TB_COSTLOSS where occur_date between in_fr_dt and in_to_dt group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_mth_concat_x_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_mth_concat_x_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_mth_concat_x_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_COSTLOSS where occur_date between last_day(in_fr_dt) and last_day(in_to_dt) and dept_name=in_dept_name group by dept_name,occur_date asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_mth_concat_x_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_mth_concat_x_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_mth_concat_x_deptname_all`( in_fr_dt date, in_to_dt date  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_COSTLOSS where occur_date between last_day(in_fr_dt) and last_day(in_to_dt) group by dept_name,occur_date asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_mth_concat_y_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_mth_concat_y_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_mth_concat_y_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) from VW_TB_COSTLOSS where occur_date between last_day(in_fr_dt) and last_day(in_to_dt) and dept_name=in_dept_name group by dept_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_costloss_mth_concat_y_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_costloss_mth_concat_y_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_costloss_mth_concat_y_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,2);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(price) from VW_TB_COSTLOSS where occur_date between last_day(in_fr_dt) and last_day(in_to_dt) group by dept_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select company_name,sum(count) as count from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt group by company_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_all`( in_fr_dt date, in_to_dt date,check_type int,company_name varchar(60) ,dept_name varchar(50)) RETURNS varchar(1024) CHARSET latin1
Begin

  Declare out_x VARCHAR(1024) default "";

  Declare test_txt_len int default 0;

  Declare test_txt VARCHAR(1024) default "";

  Declare xx VARCHAR(1024) default "";

  Declare yy VARCHAR(1024) default "";

	Declare rate VARCHAR(1024) default "";

	Declare res_diff int default 0;

	Declare isMth TINYINT(1) default 0;

	Declare isDay TINYINT(1) default 0;

	

	if timestampdiff(month,in_fr_dt,in_to_dt) >0 then 

		set isMth = 1;

	elseif timestampdiff(day,in_fr_dt,in_to_dt) >0 then 

		set isDay = 1;

	end if;

	

	if ISNULL(company_name) || LENGTH(trim(company_name))<1 then

			if dept_name="ALL" then

				set res_diff = 1; /* deptname_all */

			else 

				set res_diff = 2; /* deptname */

			end if;

		elseif ISNULL(dept_name) || LENGTH(trim(dept_name))<1  then 

			set res_diff = 3; /* companyname */

		end if;	

	

	if check_type =1 then

		if res_diff=1 then

			Select fn_tb_cust_feedback_for_deptname_all(in_fr_dt,in_to_dt) into test_txt;

		elseif res_diff=2 then

			Select fn_tb_cust_feedback_for_deptname(in_fr_dt,in_to_dt,dept_name) into test_txt;

		elseif res_diff=3 then

			Select fn_tb_cust_feedback_for_companyname(in_fr_dt,in_to_dt,company_name) into test_txt;

		end if;

		Select length(test_txt) into test_txt_len;

	elseif check_type >3 and check_type < 7 then

		Select fn_tb_cust_feedback(in_fr_dt, in_to_dt) into test_txt;

		Select length(test_txt) into test_txt_len;

		if isMth=1 and res_diff=1 then 

			Select fn_tb_cust_feedback_mth_concat_x_deptname_all(in_fr_dt,in_to_dt) into xx;

			Select fn_tb_cust_feedback_mth_concat_y_deptname_all(in_fr_dt,in_to_dt) into yy;

		elseif isMth=1 and res_diff=2 then

			Select fn_tb_cust_feedback_mth_concat_x_deptname(in_fr_dt,in_to_dt,dept_name) into xx;

			Select fn_tb_cust_feedback_mth_concat_y_deptname(in_fr_dt,in_to_dt,dept_name) into yy;

		elseif isMth=1 and res_diff=3 then

			Select fn_tb_cust_feedback_mth_concat_x_companyname(in_fr_dt,in_to_dt,company_name) into xx;

			Select fn_tb_cust_feedback_mth_concat_y_companyname(in_fr_dt,in_to_dt,company_name) into yy;

		elseif isDay=1 and res_diff=1 then

			Select fn_tb_cust_feedback_day_concat_x_deptename_all(in_fr_dt,in_to_dt) into xx;

			Select fn_tb_cust_feedback_day_concat_y_deptname_all(in_fr_dt,in_to_dt) into yy;

		elseif isDay=1 and res_diff=2 then

			Select fn_tb_cust_feedback_day_concat_x_deptname(in_fr_dt,in_to_dt,dept_name) into xx;

			Select fn_tb_cust_feedback_day_concat_y_deptname(in_fr_dt,in_to_dt,dept_name) into yy;

		elseif isDay=1 and res_diff=3 then

			Select fn_tb_cust_feedback_day_concat_x_companyname(in_fr_dt,in_to_dt,company_name) into xx;

			Select fn_tb_cust_feedback_day_concat_y_companyname(in_fr_dt,in_to_dt,company_name) into yy;

		end if;

	elseif check_type = 7 then

		Select fn_tb_cust_feedback_pareto(in_fr_dt,in_to_dt) into test_txt;

		Select length(test_txt) into test_txt_len;

		Select fn_tb_cust_feedback_pareto_concat_x (in_fr_dt,in_to_dt) into xx;

		Select fn_tb_cust_feedback_pareto_rate(in_fr_dt,in_to_dt) into rate;

	end if;

	

  if test_txt_len < 2 then

     set out_x = '{"data":null,"code":1}';

  else

		if check_type = 1 then

			set out_x = concat( '{"data":{"deptvalue":[', test_txt, ']},"code":1}');

		elseif check_type>3 and check_type<7 then		

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');

	  elseif check_type=7 then 

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"xAxisData2":[',xx,'],"deptvalue":{"reason":[', test_txt, '],"rate":[',rate,']}},"code":1}');

		end if;

		

   end if;

   return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_x_companyname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_x_companyname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_x_companyname`( in_fr_dt date, in_to_dt date,in_company_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct feedback_dt from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt and FIND_IN_SET(company_name,in_company_name) group by company_name,feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_x_deptename_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_x_deptename_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_x_deptename_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct feedback_dt from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt  group by feedback_dt,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_x_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_x_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_x_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct feedback_dt from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt and dept_name=in_dept_name group by dept_name,feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_x_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_x_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_x_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct feedback_dt from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt  group by feedback_dt,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_y_companyname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_y_companyname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_y_companyname`( in_fr_dt date, in_to_dt date,in_company_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select company_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt and FIND_IN_SET(company_name,in_company_name) group by company_name, feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_y_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_y_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_y_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt and dept_name=in_dept_name group by dept_name, feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_day_concat_y_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_day_concat_y_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_day_concat_y_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt group by dept_name, feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_for_companyname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_for_companyname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_for_companyname`( in_fr_dt date, in_to_dt date,in_company_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select company_name,sum(count) as count from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt and FIND_IN_SET(company_name,in_company_name) group by company_name asc;





Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_for_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_for_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_for_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) as count from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt and dept_name=in_dept_name group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_for_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_for_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_for_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) as count from VW_TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) group by company_name,feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_x_companyname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_x_companyname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_x_companyname`( in_fr_dt date, in_to_dt date,in_company_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) and FIND_IN_SET(company_name,in_company_name) group by company_name,feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_x_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_x_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_x_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) and dept_name=in_dept_name group by dept_name,feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_x_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_x_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_x_deptname_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) group by dept_name,feedback_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select company_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between last_day('2019-09-01') and last_day('2019-12-01') group by company_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_y_companyname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_y_companyname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_y_companyname`( in_fr_dt date, in_to_dt date,in_company_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select company_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) and FIND_IN_SET(company_name,in_company_name) group by company_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_y_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_y_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_y_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) and dept_name=in_dept_name group by dept_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_mth_concat_y_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_mth_concat_y_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_mth_concat_y_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_CUST_FEEDBACK where feedback_dt between last_day(in_fr_dt) and last_day(in_to_dt) group by dept_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_pareto` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_pareto` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_pareto`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select feedback_reason,count(*) as feedback_count from TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt GROUP BY feedback_reason order by count(*) desc limit 7;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x, convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , ',', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_pareto_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_pareto_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_pareto_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(255);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct feedback_reason from TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt group by feedback_reason order by count(*) desc limit 7;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_cust_feedback_pareto_rate` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_cust_feedback_pareto_rate` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_cust_feedback_pareto_rate`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(255);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select ROUND(count(*)/(select count(*) from TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt limit 7),2) as percent from TB_CUST_FEEDBACK where feedback_dt between in_fr_dt and in_to_dt group by feedback_reason order by count(*) desc limit 7;





Declare continue handler for not found set is_done=1;

Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = (s_name*100);

else

	Set out_x = concat(out_x,',',(s_name)*100, '');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_day_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_day_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_day_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

  Declare out_x VARCHAR(1024) default "";

  Declare test_txt_len int default 0;

  Declare test_txt VARCHAR(1024) default "";

  Declare xx VARCHAR(1024) default "";

  Declare yy VARCHAR(1024) default "";



  Select fn_tb_elec_day_concat_y_all(in_fr_dt,in_to_dt) into test_txt;

  Select length(test_txt) into test_txt_len;

  Select fn_tb_elec_day_concat_x(in_fr_dt,in_to_dt) into xx;

  Select fn_tb_elec_day_concat_y_all(in_fr_dt,in_to_dt) into yy;



  if test_txt_len < 2 then

     set out_x = '{"data":null,"code":1}';

  else

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');

   end if;

   return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_day_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_day_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_day_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name date;
Declare csr1 CURSOR for select distinct dt from VW_TB_ELEC_DAY where dt between in_fr_dt and in_to_dt order by dept_code,dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',s_name , '"');
else
Set out_x = concat(out_x,',"',s_name, '"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_day_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_day_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_day_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_ELEC_DAY where dt between in_fr_dt and in_to_dt order by dept_code, dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_day_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_day_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_day_concat_y_one`( in_fr_dt date , in_to_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_ELEC_DAY where dt between in_fr_dt and in_to_dt and dept_code = in_dept_code order by dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_day_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_day_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_day_one`( in_fr_dt date, in_to_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_elec_day_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_elec_day_concat_x(in_fr_dt, in_to_dt) into xx;
  Select fn_tb_elec_day_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_hr_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_hr_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_hr_all`( in_dt date , unused_dt date  ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_elec_hr_concat_y_all(in_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_elec_hr_concat_x(in_dt) into xx;
  Select fn_tb_elec_hr_concat_y_all(in_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_hr_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_hr_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_hr_concat_x`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select distinct tm from VW_TB_ELEC_HR where dt = in_dt order by dept_code,tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',hour(s_name) , ':00"');
else
Set out_x = concat(out_x,',"',hour(s_name) , ':00"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_hr_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_hr_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_hr_concat_y_all`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_ELEC_HR where dt = in_dt order by dept_code, tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_hr_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_hr_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_hr_concat_y_one`( in_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_ELEC_HR where dt = in_dt and dept_code = in_dept_code order by tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_hr_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_hr_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_hr_one`( in_dt date , unused_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_elec_hr_concat_y_one(in_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_elec_hr_concat_x(in_dt) into xx;
  Select fn_tb_elec_hr_concat_y_one(in_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_mth_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_mth_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_mth_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_elec_mth_concat_y_all(in_fr_dt,in_to_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_elec_mth_concat_x(in_fr_dt,in_to_dt) into xx;
  Select fn_tb_elec_mth_concat_y_all(in_fr_dt,in_to_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_mth_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_mth_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_mth_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_ELEC_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) order by dept_code,last_day_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_mth_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_mth_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_mth_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_ELEC_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) order by dept_code, last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_mth_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_mth_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_mth_concat_y_one`( in_fr_dt date , in_to_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_ELEC_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) and dept_code = in_dept_code order by last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_elec_mth_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_elec_mth_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_elec_mth_one`( in_fr_dt date, in_to_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_elec_mth_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_elec_mth_concat_x(in_fr_dt, in_to_dt) into xx;
  Select fn_tb_elec_mth_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_insert_chart_by_userid` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_insert_chart_by_userid` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_insert_chart_by_userid`(in_userid int(11),in_chartid int(11),in_chartname varchar(30),in_fr date,in_to date,in_create date,in_create_by varchar(30)) RETURNS varchar(1024) CHARSET latin1
BEGIN
        DECLARE out_x VARCHAR(1024) DEFAULT "code:1";
	insert into TB_USER_CHART 
	(userid,chartid,chart_name,fr_dt,to_dt,create_dt,create_by)
	values
	(in_userid,in_chartid,in_chartname,in_fr,in_to,in_create,in_create_by);
        RETURN out_x;
    END */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_day_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_day_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_day_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_part_day_concat_y_all(in_fr_dt,in_to_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_part_day_concat_x(in_fr_dt,in_to_dt) into xx;
  Select fn_tb_part_day_concat_y_all(in_fr_dt,in_to_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_day_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_day_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_day_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name date;
Declare csr1 CURSOR for select distinct dt from VW_TB_PARTICLE_DAY where dt between in_fr_dt and in_to_dt order by dept_code,dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',s_name , '"');
else
Set out_x = concat(out_x,',"',s_name, '"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_day_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_day_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_day_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_PARTICLE_DAY where dt between in_fr_dt and in_to_dt order by dept_code, dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_day_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_day_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_day_concat_y_one`( in_fr_dt date , in_to_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_PARTICLE_DAY where dt between in_fr_dt and in_to_dt and dept_code = in_dept_code order by dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_day_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_day_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_day_one`( in_fr_dt date, in_to_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_part_day_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_part_day_concat_x(in_fr_dt, in_to_dt) into xx;
  Select fn_tb_part_day_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_hr_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_hr_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_hr_all`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_part_hr_concat_y_all(in_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_part_hr_concat_x(in_dt) into xx;
  Select fn_tb_part_hr_concat_y_all(in_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_hr_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_hr_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_hr_concat_x`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select distinct tm from VW_TB_PARTICLE_HR where dt = in_dt order by dept_code,tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',hour(s_name) , ':00"');
else
Set out_x = concat(out_x,',"',hour(s_name) , ':00"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_hr_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_hr_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_hr_concat_y_all`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_PARTICLE_HR where dt = in_dt order by dept_code, tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_hr_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_hr_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_hr_concat_y_one`( in_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_PARTICLE_HR where dt = in_dt and dept_code = in_dept_code order by tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_hr_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_hr_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_hr_one`( in_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_part_hr_concat_y_one(in_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_part_hr_concat_x(in_dt) into xx;
  Select fn_tb_part_hr_concat_y_one(in_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_mth_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_mth_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_mth_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_part_mth_concat_y_all(in_fr_dt,in_to_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_part_mth_concat_x(in_fr_dt,in_to_dt) into xx;
  Select fn_tb_part_mth_concat_y_all(in_fr_dt,in_to_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_mth_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_mth_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_mth_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name varchar(7);
Declare fr_mth_yr date;
Declare to_mth_yr date;
Declare csr1 CURSOR for select distinct yr_mth from VW_TB_PARTICLE_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) order by dept_code,last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',s_name , '"');
else
Set out_x = concat(out_x,',"',s_name, '"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_mth_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_mth_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_mth_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_PARTICLE_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) order by dept_code, last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_mth_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_mth_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_mth_concat_y_one`( in_fr_dt date , in_to_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_PARTICLE_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) and dept_code = in_dept_code order by last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_part_mth_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_part_mth_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_part_mth_one`( in_fr_dt date, in_to_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_part_mth_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_part_mth_concat_x(in_fr_dt, in_to_dt) into xx;
  Select fn_tb_part_mth_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_thickness` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_thickness` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_thickness`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,3);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select customer,TRUNCATE(thickness,3) as count from VW_TB_THICKNESS where occur_date between in_fr_dt and in_to_dt;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', TRUNCATE(tmp_count, 3));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', TRUNCATE(tmp_count, 3),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', TRUNCATE(tmp_count, 3),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_thickness_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_thickness_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_thickness_all`( in_fr_dt date, in_to_dt date,check_type int,part_id varchar(50)) RETURNS varchar(1024) CHARSET latin1
Begin

  Declare out_x VARCHAR(1024) default "";

  Declare test_txt_len int default 0;

  Declare test_txt VARCHAR(1024) default "";

  Declare xx VARCHAR(1024) default "";

  Declare yy VARCHAR(1024) default "";

	Declare rate VARCHAR(1024) default "";

	Declare res_diff int default 0;

	Declare isMth TINYINT(1) default 0;

	Declare isDay TINYINT(1) default 0;

	

	

	if check_type >3 and check_type < 7 then

		Select fn_tb_thickness(in_fr_dt, in_to_dt) into test_txt;

		Select length(test_txt) into test_txt_len;

			Select fn_tb_thickness_day_concat_x_part(in_fr_dt,in_to_dt,part_id) into xx;

			Select fn_tb_thickness_day_concat_y_part(in_fr_dt,in_to_dt,part_id) into yy;

	end if;

	

  if test_txt_len < 2 then

     set out_x = '{"data":null,"code":1}';

  else

		if check_type = 1 then

			set out_x = concat( '{"data":{"deptvalue":[', test_txt, ']},"code":1}');

		elseif check_type>3 and check_type<7 then		

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');

	  elseif check_type=7 then 

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"xAxisData2":[',xx,'],"deptvalue":{"reason":[', test_txt, '],"rate":[',rate,']}},"code":1}');

		end if;

		

   end if;

   return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_thickness_day_concat_x_part` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_thickness_day_concat_x_part` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_thickness_day_concat_x_part`( in_fr_dt date, in_to_dt date,in_part_id varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct occur_date from VW_TB_THICKNESS where occur_date between in_fr_dt and in_to_dt and part_id=in_part_id;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_thickness_day_concat_y_part` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_thickness_day_concat_y_part` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_thickness_day_concat_y_part`( in_fr_dt date, in_to_dt date,in_part_id varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,3);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select customer,TRUNCATE(thickness,3) from VW_TB_THICKNESS where occur_date between in_fr_dt and in_to_dt and part_id=in_part_id;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_thickness_mth_concat_x_part` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_thickness_mth_concat_x_part` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_thickness_mth_concat_x_part`( in_fr_dt date, in_to_dt date,in_part_id varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_THICKNESS where occur_date between last_day(in_fr_dt) and last_day(in_to_dt) and part_id=in_part_id;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_thickness_mth_concat_y_part` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_thickness_mth_concat_y_part` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_thickness_mth_concat_y_part`( in_fr_dt date, in_to_dt date,in_part_id varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,3);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select customer,TRUNCATE(thickness,3) from VW_TB_THICKNESS where occur_date between last_day(in_fr_dt) and last_day(in_to_dt) and part_id=in_part_id;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) as count from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_all`( in_fr_dt date, in_to_dt date,check_type int,dept_name varchar(50)) RETURNS varchar(1024) CHARSET latin1
Begin

  Declare out_x VARCHAR(1024) default "";

  Declare test_txt_len int default 0;

  Declare test_txt VARCHAR(1024) default "";

  Declare xx VARCHAR(1024) default "";

  Declare yy VARCHAR(1024) default "";

	Declare rate VARCHAR(1024) default "";

	Declare res_diff int default 0;

	Declare isMth TINYINT(1) default 0;

	Declare isDay TINYINT(1) default 0;

	

	if timestampdiff(month,in_fr_dt,in_to_dt) >0 then 

		set isMth = 1;

	elseif timestampdiff(day,in_fr_dt,in_to_dt) >0 then 

		set isDay = 1;

	end if;

	

	if dept_name="ALL" then

		set res_diff = 1; /* deptname_all */

	else 

		set res_diff = 2; /* deptname */

	end if;



	if check_type =1 then

			if dept_name="ALL" then

				Select fn_tb_unqualified_for_deptname_all(in_fr_dt,in_to_dt) into test_txt;

			else

				Select fn_tb_unqualified_for_deptname(in_fr_dt,in_to_dt,dept_name) into test_txt;

			end if;

		Select length(test_txt) into test_txt_len;

	elseif check_type >3 and check_type < 7 then

		Select fn_tb_unqualified(in_fr_dt, in_to_dt) into test_txt;

		Select length(test_txt) into test_txt_len;

		if isMth=1 and res_diff=1 then 

			Select fn_tb_unqualified_mth_concat_x_deptname_all(in_fr_dt,in_to_dt) into xx;

			Select fn_tb_unqualified_mth_concat_y_deptname_all(in_fr_dt,in_to_dt) into yy;

		elseif isMth=1 and res_diff=2 then

			Select fn_tb_unqualified_mth_concat_x_deptname(in_fr_dt,in_to_dt,dept_name) into xx;

			Select fn_tb_unqualified_mth_concat_y_deptname(in_fr_dt,in_to_dt,dept_name) into yy;

		elseif isDay=1 and res_diff=1 then

			Select fn_tb_unqualified_day_concat_x_deptname_all(in_fr_dt,in_to_dt) into xx;

			Select fn_tb_unqualified_day_concat_y_deptname_all(in_fr_dt,in_to_dt) into yy;

		elseif isDay=1 and res_diff=2 then

			Select fn_tb_unqualified_day_concat_x_deptname(in_fr_dt,in_to_dt,dept_name) into xx;

			Select fn_tb_unqualified_day_concat_y_deptname(in_fr_dt,in_to_dt,dept_name) into yy;

		end if;

	elseif check_type = 7 then

		Select fn_tb_unqualified_pareto(in_fr_dt,in_to_dt) into test_txt;

		Select length(test_txt) into test_txt_len;

		Select fn_tb_unqualified_pareto_concat_x (in_fr_dt,in_to_dt) into xx;

		Select fn_tb_unqualified_pareto_rate(in_fr_dt,in_to_dt) into rate;

	end if;

	

  if test_txt_len < 2 then

     set out_x = '{"data":null,"code":1}';

  else

		if check_type = 1 then

			set out_x = concat( '{"data":{"deptvalue":[', test_txt, ']},"code":1}');

		elseif check_type>3 and check_type<7 then		

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');

	  elseif check_type=7 then 

     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"xAxisData2":[',xx,'],"deptvalue":{"reason":[', test_txt, '],"rate":[',rate,']}},"code":1}');

		end if;

		

   end if;

   return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_day_concat_x_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_day_concat_x_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_day_concat_x_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct unqualified_dt from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt and dept_name=in_dept_name group by unqualified_dt,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_day_concat_x_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_day_concat_x_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_day_concat_x_deptname_all`( in_fr_dt date, in_to_dt date  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(1024);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct unqualified_dt from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt group by unqualified_dt,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_day_concat_y_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_day_concat_y_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_day_concat_y_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt and dept_name=in_dept_name group by unqualified_dt,dept_name  asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_day_concat_y_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_day_concat_y_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_day_concat_y_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt group by unqualified_dt,dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_for_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_for_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_for_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60) ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) as count from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt and dept_name=in_dept_name group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_for_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_for_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_for_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_company_name varchar(30);

Declare tmp_last_company_name varchar(30) default "";

Declare tmp_count decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) as count from VW_TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt group by dept_name asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_company_name,tmp_count;

If is_done = 1 then



  Leave get_list;

End if;

Select strcmp(tmp_company_name, tmp_last_company_name) into cnt;

If cnt = 0 then 

       Set out_x = concat(out_x,',', convert(tmp_count, char));

Elseif start >= 1 then 

       Set out_x = concat(out_x , ',{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



else

       Set start = start + 1;

       Set out_x = concat(out_x ,'{"name":"',tmp_company_name , '","value":', convert(tmp_count, char),'}');



End if;

Set  tmp_last_company_name = tmp_company_name;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_mth_concat_x_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_mth_concat_x_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_mth_concat_x_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_UNQUALIFIED where unqualified_dt between last_day(in_fr_dt) and last_day(in_to_dt) and dept_name=in_dept_name group by dept_name,unqualified_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_mth_concat_x_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_mth_concat_x_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_mth_concat_x_deptname_all`( in_fr_dt date, in_to_dt date  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(7);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct yr_mth from VW_TB_UNQUALIFIED where unqualified_dt between last_day(in_fr_dt) and last_day(in_to_dt) group by dept_name,unqualified_dt asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_mth_concat_y_deptname` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_mth_concat_y_deptname` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_mth_concat_y_deptname`( in_fr_dt date, in_to_dt date,in_dept_name varchar(60)  ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_UNQUALIFIED where unqualified_dt between last_day(in_fr_dt) and last_day(in_to_dt) and dept_name=in_dept_name group by dept_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_mth_concat_y_deptname_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_mth_concat_y_deptname_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_mth_concat_y_deptname_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select dept_name,sum(count) from VW_TB_UNQUALIFIED where unqualified_dt between last_day(in_fr_dt) and last_day(in_to_dt) group by dept_name, yr_mth asc;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x,',', convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_pareto` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_pareto` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_pareto`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

Declare start int default 0;

Declare tmp_dept varchar(30);

Declare tmp_last_dept varchar(30) default "";

Declare tmp_inc_value decimal(32,0);

Declare out_x VARCHAR(1024) default "";



Declare s_name time;



Declare csr1 CURSOR for select unqualified_reason,count(*) as unqualified_count from TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt GROUP BY unqualified_reason order by count(*) desc limit 7;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP

Fetch csr1 into tmp_dept,tmp_inc_value;

If is_done = 1 then

 

  Leave get_list;

End if;

Select strcmp(tmp_dept, tmp_last_dept) into cnt;

If cnt = 0 then 

	Set out_x = concat(out_x, convert(tmp_inc_value, char));

Elseif start >= 1 then 

	Set out_x = concat(out_x , ',', convert(tmp_inc_value, char));



else

	Set start = start + 1;

	Set out_x = concat(out_x ,'', convert(tmp_inc_value, char));



End if;

Set tmp_last_dept = tmp_dept;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_pareto_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_pareto_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_pareto_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(255);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select distinct unqualified_reason from TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt group by unqualified_reason order by count(*) desc limit 7;



Declare continue handler for not found set is_done=1;



Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = concat('"',s_name , '"');

else

	Set out_x = concat(out_x,',"',s_name, '"');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_unqualified_pareto_rate` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_unqualified_pareto_rate` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_unqualified_pareto_rate`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin

Declare is_done int default 0;

Declare cnt int default 0;

declare out_x VARCHAR(1024) default "";

Declare s_name varchar(255);

Declare fr_mth_yr date;

Declare to_mth_yr date;



Declare csr1 CURSOR for select ROUND(count(*)/(select count(*) from TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt limit 7),2) as percent from TB_UNQUALIFIED where unqualified_dt between in_fr_dt and in_to_dt group by unqualified_reason order by count(*) desc limit 7;





Declare continue handler for not found set is_done=1;

Open csr1;



get_list: LOOP



Fetch csr1 into s_name;

If is_done = 1 then

  Leave get_list;

End if;



If cnt = 0 then

	Set out_x = (s_name*100);

else

	Set out_x = concat(out_x,',',(s_name)*100, '');

End if;

Set cnt =  1;

End loop get_list;

Close csr1;

Return out_x;

End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_user_chart_delete_by_chartid` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_user_chart_delete_by_chartid` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_user_chart_delete_by_chartid`(in_chart_id  VARCHAR(50)) RETURNS varchar(1024) CHARSET latin1
BEGIN

        DECLARE out_x VARCHAR(1024) DEFAULT '{"code":1}';

        declare cnt VARCHAR(50) default 0;

        

        select count(*)  INTO cnt from TB_USER_CHART where chartid = in_chart_id;

	

        if cnt = 0 then

		set out_x = '{"code":2}';

	end if;

		

        delete FROM TB_USER_CHART WHERE chartid = in_chart_id  ;

        DELETE FROM TB_CHART WHERE chartid = in_chart_id  ;

        #判断userchart 有没有这个表，有的话删除，没有的话返回 code:2

        #tb_chart 没有chartid,需要添加。

        

        RETURN out_x;

    END */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_user_chart_insert_by_userid` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_user_chart_insert_by_userid` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_user_chart_insert_by_userid`(in_userid varchar(100),in_user_name varchar(100),json_format VARCHAR(2048) ) RETURNS varchar(1024) CHARSET utf8
BEGIN

        DECLARE out_x VARCHAR(1024) DEFAULT '{"code":1}';

				declare in_lineindex int(11) default JSON_EXTRACT(json_format, '$.lineindex');

				DECLARE in_chartid varchar(100) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.chartid'));

				DECLARE in_seriestype VARCHAR(255) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.seriestype'));

				DECLARE in_ul DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.ul');

				DECLARE in_ll DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.ll');

				DECLARE in_cl_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_std_dev');

				DECLARE in_cl_add1_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_add1_std_dev');

				DECLARE in_cl_add2_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_add2_std_dev');

				DECLARE in_cl_add3_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_add3_std_dev');

				DECLARE in_cl_less1_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_less1_std_dev');

				DECLARE in_cl_less2_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_less2_std_dev');

				DECLARE in_cl_less3_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_less3_std_dev');

				DECLARE in_reportname VARCHAR(255) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.reportname'));

				DECLARE in_chartremark VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.chartremark'));

				DECLARE in_xAxisData VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.xAxisData'));

				DECLARE in_xAxisData2 VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.xAxisData2'));

				DECLARE in_yAxisUnit VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.yAxisUnit'));				

				DECLARE in_yAxisUnit2 VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.yAxisUnit2'));	

				DECLARE in_deptvalue VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.deptvalue'));	

				DECLARE in_resource INT(11) DEFAULT JSON_EXTRACT(json_format, '$.resource');						

				DECLARE in_part_id VARCHAR(30) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.partid'));

				

				DECLARE in_fr DATE DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.fr_dt')); 

				DECLARE in_to DATE DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.to_dt')); 

				

	INSERT INTO TB_USER_CHART 

	(userid,user_name,chart_name,chartid,fr_dt,to_dt,create_dt,create_by,last_mod_by,last_mod_dt)

	VALUES

	(in_userid,in_user_name,in_reportname,in_chartid,in_fr,in_to,CURRENT_DATE(),in_userid,in_userid,CURRENT_DATE());

	

	INSERT INTO TB_CHART 

	(TB_CHART.`chartid`,TB_CHART.`chart_name`,TB_CHART.`seriestype`,TB_CHART.`ul`,TB_CHART.`ll`,TB_CHART.`cl_std_dev`,

	TB_CHART.`cl_add1_std_dev`,TB_CHART.`cl_add2_std_dev`,TB_CHART.`cl_add3_std_dev`,TB_CHART.`cl_less1_std_dev`,

	TB_CHART.`cl_less2_std_dev`,TB_CHART.`cl_less3_std_dev`,TB_CHART.`chartremark`,TB_CHART.`xAxisData`,TB_CHART.`xAxisData2`,

	TB_CHART.`yAxisUnit`,TB_CHART.`yAxisUnit2`,TB_CHART.`deptvalue`,TB_CHART.`resource`,TB_CHART.`part_id`, create_dt,lineindex,

	last_mod_by,last_mod_dt,create_by)

	VALUES

	(in_chartid,in_reportname,in_seriestype,in_ul,in_ll,in_cl_std_dev,in_cl_add1_std_dev,in_cl_add2_std_dev,in_cl_add3_std_dev,

	in_cl_less1_std_dev,in_cl_less2_std_dev,in_cl_less3_std_dev,in_chartremark,in_xAxisData,in_xAxisData2,in_yAxisUnit,

	in_yAxisUnit2,in_deptvalue,in_resource,in_part_id,CURRENT_DATE(),in_lineindex,

	in_userid,current_date(),in_userid);

  

	RETURN out_x;

    END */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_user_chart_search_by_userid` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_user_chart_search_by_userid` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_user_chart_search_by_userid`(in_userid VARCHAR(100)) RETURNS longtext CHARSET utf8
BEGIN

	DECLARE is_done INT DEFAULT 0;

	DECLARE cnt INT DEFAULT 0;

	DECLARE out_x text(6553500) DEFAULT "";

				#DECLARE in_chart_name VARCHAR(100) DEFAULT "";和reportname是什么关系

				

				DECLARE in_chartid VARCHAR(50) DEFAULT "";

				DECLARE in_seriestype VARCHAR(255) DEFAULT "";

				DECLARE in_lineindex INT(11) DEFAULT 0;

				DECLARE in_ul DECIMAL(11,2) DEFAULT 0;

				DECLARE in_ll DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_add1_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_add2_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_add3_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_less1_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_less2_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_cl_less3_std_dev DECIMAL(11,2) DEFAULT 0;

				DECLARE in_chart_name VARCHAR(255) DEFAULT "";

				DECLARE in_chartremark VARCHAR(1024) DEFAULT "";

				DECLARE in_xAxisData VARCHAR(1024) DEFAULT "";

				DECLARE in_xAxisData2 VARCHAR(1024) DEFAULT "";

				DECLARE in_yAxisUnit VARCHAR(1024) DEFAULT "";				

				DECLARE in_yAxisUnit2 VARCHAR(1024) DEFAULT "";	

				DECLARE in_deptvalue VARCHAR(1024) DEFAULT "";	

				DECLARE in_resource INT(11) DEFAULT 0;			

				DECLARE in_part_id VARCHAR(30) DEFAULT "";			

				

				DECLARE in_fr_dt DATE DEFAULT '2020-2-25'; 

				DECLARE in_to_dt DATE DEFAULT '2020-2-25'; 

	

	#DECLARE ob1 VARCHAR(65534) DEFAULT "";

	#DECLARE ob1 TEXT(65535) DEFAULT "";

	DECLARE ob1 json DEFAULT "{}";	

	#DECLARE arr1 TEXT(6553500) DEFAULT "";

	DECLARE arr1 json DEFAULT "[]";

	/*

	SELECT json_object('aaa', 1, 'bbb', 2, 'ddd', 3) INTO ob1;

	

	SELECT json_object('aaa', 2, 'bbb', 3, 'ddd', 'ww') INTO ob2;

	SELECT json_array(ob1,ob2) INTO ar1;

	SELECT json_object('aaa', 3, 'bbb', 6, 'ddd', "") INTO ob1;

	SELECT json_array_insert(ar1,'$.0',ob1) INTO out_x;

	SELECT json_array_append('[1,2]','$',3) INTO out_x;	

		*/

#	DECLARE csr1 CURSOR FOR SELECT DISTINCT occur_date FROM VW_TB_THICKNESS WHERE occur_date BETWEEN in_fr_dt AND in_to_dt AND part_id=in_part_id;	

	DECLARE csr1 CURSOR FOR SELECT DISTINCT b.`chartid`,b.`chart_name`,b.`seriestype`,b.`lineindex`,b.`ul`,b.`ll`,

	b.cl_std_dev,b.cl_add1_std_dev,b.cl_add3_std_dev,b.cl_add2_std_dev,b.cl_less1_std_dev,

	b.cl_less2_std_dev,b.cl_less3_std_dev,b.chart_name,b.chartremark,b.xAxisData,b.xAxisData2,

	b.yAxisUnit,b.yAxisUnit2,a.fr_dt,a.to_dt,b.resource ,b.part_id,b.deptvalue

		

	FROM  TB_USER_CHART a INNER JOIN TB_CHART b ON( a.userid =in_userid AND a.chartid = b.`chartid`);

	

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_done=1;

	OPEN csr1;

		

#	SELECT COUNT(*) into cnt FROM  TB_USER_CHART a INNER JOIN TB_CHART b ON( a.userid =in_userid AND a.chartid = b.`chartid`);

	#SELECT json_array(NULL) into arr1;

	

	get_list: LOOP

	FETCH csr1 INTO 	in_chartid,in_chart_name,in_seriestype,in_lineindex,in_ul,in_ll,

	in_cl_std_dev,in_cl_add1_std_dev,in_cl_add3_std_dev,in_cl_add2_std_dev,in_cl_less1_std_dev,

	in_cl_less2_std_dev,in_cl_less3_std_dev,in_chart_name,in_chartremark,in_xAxisData,in_xAxisData2,

	in_yAxisUnit,in_yAxisUnit2,in_fr_dt,in_to_dt,in_resource,in_part_id,in_deptvalue;

	IF is_done = 1 THEN

	  LEAVE get_list;

	END IF;

	set cnt = cnt+1;

	SELECT json_object(

	'chartid', in_chartid,'chart_name',in_chart_name,'seriestype', in_seriestype

	,'lineindex',in_lineindex 

	,'ul',in_ul ,'ll', in_ll

	,'cl_std_dev',in_cl_std_dev 

	,'cl_add1_std_dev', in_cl_add1_std_dev,'cl_add3_std_dev', in_cl_add3_std_dev,'cl_add2_std_dev',in_cl_add2_std_dev 

	,'cl_less1_std_dev', in_cl_less1_std_dev,'cl_less2_std_dev', in_cl_less2_std_dev,'cl_less3_std_dev',in_cl_less3_std_dev 

	,'chart_name', in_chart_name,'chartremark', in_chartremark,'xAxisData',in_xAxisData ,'xAxisData2',in_xAxisData2

	,'yAxisUnit', in_yAxisUnit,'yAxisUnit2', in_yAxisUnit2,'fr_dt', in_fr_dt,'to_dt',in_to_dt ,'resource', in_resource,'partid',in_part_id,'deptvalue',in_deptvalue

	) INTO ob1;

/**/

	#SELECT json_object('chartid', in_chartid,'chart_name',in_chart_name) into ob1;

	SELECT json_array_append(arr1,'$',(ob1)) into arr1;

	

	END LOOP get_list;

	CLOSE csr1;

	

	if cnt = 0 then

		SELECT json_object('data',null,'code',1) INTO ob1;

	else

	

		SELECT json_object('charts',(arr1)) into ob1;

		SELECT json_object('data',(ob1),'code',1) INTO ob1;

	#SELECT REPLACE(ob1,'\\','') into out_x;

	end if;

	

	set out_x = ob1;

	#set out_x = concat(cnt);

	RETURN out_x;

END */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_user_chart_update_by_chartid` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_user_chart_update_by_chartid` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_user_chart_update_by_chartid`(in_userid varchar(50),json_format VARCHAR(2048)) RETURNS varchar(1024) CHARSET latin1
BEGIN

        DECLARE out_x VARCHAR(1024) DEFAULT '{"code":1}';   

        declare cnt int(11) default 0;				

				declare in_lineindex int(11) default JSON_EXTRACT(json_format, '$.lineindex');

				DECLARE in_chartid varchar(30) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.chartid'));

				DECLARE in_seriestype VARCHAR(255) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.seriestype'));

				DECLARE in_ul DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.ul');

				DECLARE in_ll DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.ll');

				DECLARE in_cl_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_std_dev');

				DECLARE in_cl_add1_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_add1_std_dev');

				DECLARE in_cl_add2_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_add2_std_dev');

				DECLARE in_cl_add3_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_add3_std_dev');

				DECLARE in_cl_less1_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_less1_std_dev');

				DECLARE in_cl_less2_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_less2_std_dev');

				DECLARE in_cl_less3_std_dev DECIMAL(11,2) DEFAULT JSON_EXTRACT(json_format, '$.cl_less3_std_dev');

				DECLARE in_reportname VARCHAR(255) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.reportname'));

				DECLARE in_chartremark VARCHAR(50) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.chartremark'));

				DECLARE in_xAxisData VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.xAxisData'));

				DECLARE in_xAxisData2 VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.xAxisData2'));

				DECLARE in_yAxisUnit VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.yAxisUnit'));				

				DECLARE in_yAxisUnit2 VARCHAR(1024) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.yAxisUnit2'));	

				DECLARE in_deptvalue VARCHAR(1024) DEFAULT JSON_EXTRACT(json_format, '$.deptvalue');	

				DECLARE in_resource INT(11) DEFAULT JSON_EXTRACT(json_format, '$.resource');		

				DECLARE in_part_id VARCHAR(30) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.partid'));				

				

				DECLARE in_fr VARCHAR(50) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.to_dt'));

				DECLARE in_to VARCHAR(50) DEFAULT json_unquote(JSON_EXTRACT(json_format, '$.fr_dt'));

				declare in_lineidex int(11) DEFAULT JSON_EXTRACT(json_format, '$.lineindex');

				

	select count(*) into cnt from TB_CHART where 	chartid = in_chartid;

	

	if cnt = 0 then 

		set out_x = '{"code":2}';

	else	

		UPDATE  TB_USER_CHART set

		chart_name=in_reportname,fr_dt=in_fr,to_dt=in_to,

		last_mod_by=in_userid,last_mod_dt =CURRENT_DATE()

		where chartid =in_chartid;

	

		update  TB_CHART set 

		`seriestype`=in_seriestype,ul =in_ul,ll=in_ll,cl_std_dev=in_cl_std_dev,

		cl_add1_std_dev=in_cl_add1_std_dev,cl_add2_std_dev=in_cl_add2_std_dev,

		cl_add3_std_dev=in_cl_add3_std_dev,cl_less1_std_dev=in_cl_less1_std_dev,

		cl_less2_std_dev=in_cl_less2_std_dev,cl_less3_std_dev=in_cl_less3_std_dev,

		chart_name=in_reportname,chartremark=in_chartremark,xAxisData=in_xAxisData,

		xAxisData2=in_xAxisData2,yAxisUnit=in_yAxisUnit,yAxisUnit2=in_yAxisUnit2,

		deptvalue=in_deptvalue,resource=in_resource,lineindex=in_lineindex,part_id=in_part_id,last_mod_by=in_userid,last_mod_dt =CURRENT_DATE()

		where chartid = in_chartid;

		

	end if;	

	

        RETURN out_x;

    END */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_day_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_day_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_day_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_water_day_concat_y_all(in_fr_dt,in_to_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_water_day_concat_x(in_fr_dt,in_to_dt) into xx;
  Select fn_tb_water_day_concat_y_all(in_fr_dt,in_to_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_day_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_day_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_day_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name date;
Declare csr1 CURSOR for select distinct dt from VW_TB_WATER_DAY where dt between in_fr_dt and in_to_dt order by dept_code,dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',s_name , '"');
else
Set out_x = concat(out_x,',"',s_name, '"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_day_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_day_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_day_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_WATER_DAY where dt between in_fr_dt and in_to_dt order by dept_code, dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_day_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_day_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_day_concat_y_one`( in_fr_dt date , in_to_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_WATER_DAY where dt between in_fr_dt and in_to_dt and dept_code = in_dept_code order by dt asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_day_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_day_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_day_one`( in_fr_dt date, in_to_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_water_day_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_water_day_concat_x(in_fr_dt, in_to_dt) into xx;
  Select fn_tb_water_day_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_hr_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_hr_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_hr_all`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_water_hr_concat_y_all(in_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_water_hr_concat_x(in_dt) into xx;
  Select fn_tb_water_hr_concat_y_all(in_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_hr_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_hr_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_hr_concat_x`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select distinct tm from VW_TB_WATER_HR where dt = in_dt order by dept_code,tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',hour(s_name) , ':00"');
else
Set out_x = concat(out_x,',"',hour(s_name) , ':00"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_hr_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_hr_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_hr_concat_y_all`( in_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_WATER_HR where dt = in_dt order by dept_code, tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_hr_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_hr_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_hr_concat_y_one`( in_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_WATER_HR where dt = in_dt and dept_code = in_dept_code order by tm asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_hr_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_hr_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_hr_one`( in_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_water_hr_concat_y_one(in_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_water_hr_concat_x(in_dt) into xx;
  Select fn_tb_water_hr_concat_y_one(in_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_mth_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_mth_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_mth_all`( in_fr_dt date, in_to_dt date) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_water_mth_concat_y_all(in_fr_dt,in_to_dt) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_water_mth_concat_x(in_fr_dt,in_to_dt) into xx;
  Select fn_tb_water_mth_concat_y_all(in_fr_dt,in_to_dt) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_mth_concat_x` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_mth_concat_x` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_mth_concat_x`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
declare out_x VARCHAR(1024) default "";
Declare s_name varchar(7);
Declare fr_mth_yr date;
Declare to_mth_yr date;
Declare csr1 CURSOR for select distinct yr_mth from VW_TB_WATER_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) order by dept_code,last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into s_name;
If is_done = 1 then
  Leave get_list;
End if;
If cnt = 0 then
Set out_x = concat('"',s_name , '"');
else
Set out_x = concat(out_x,',"',s_name, '"');
End if;
Set cnt =  1;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_mth_concat_y_all` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_mth_concat_y_all` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_mth_concat_y_all`( in_fr_dt date, in_to_dt date ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_WATER_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) order by dept_code, last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_mth_concat_y_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_mth_concat_y_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_mth_concat_y_one`( in_fr_dt date , in_to_dt date , in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
Declare is_done int default 0;
Declare cnt int default 0;
Declare start int default 0;
Declare tmp_dept varchar(30);
Declare tmp_last_dept varchar(30) default "";
Declare tmp_inc_value decimal(32,0);
Declare out_x VARCHAR(1024) default "";
Declare s_name time;
Declare csr1 CURSOR for select dept,inc_value from VW_TB_WATER_MTH where last_day_mth between last_day(in_fr_dt) and last_day(in_to_dt) and dept_code = in_dept_code order by last_day_mth asc;
Declare continue handler for not found set is_done=1;
Open csr1;
get_list: LOOP
Fetch csr1 into tmp_dept,tmp_inc_value;
If is_done = 1 then
 
  Leave get_list;
End if;
Select strcmp(tmp_dept, tmp_last_dept) into cnt;
If cnt = 0 then 
Set out_x = concat(out_x,',', convert(tmp_inc_value, char));
Elseif start >= 1 then 
Set out_x = concat(out_x , '],"',tmp_dept , '":[', convert(tmp_inc_value, char));
else
Set start = start + 1;
Set out_x = concat(out_x ,'"',tmp_dept , '":[', convert(tmp_inc_value, char));
End if;
Set tmp_last_dept = tmp_dept;
End loop get_list;
Close csr1;
Return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `fn_tb_water_mth_one` */

/*!50003 DROP FUNCTION IF EXISTS `fn_tb_water_mth_one` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `fn_tb_water_mth_one`( in_fr_dt date, in_to_dt date, in_dept_code int(11) ) RETURNS varchar(1024) CHARSET latin1
Begin
  Declare out_x VARCHAR(1024) default "";
  Declare test_txt_len int default 0;
  Declare test_txt VARCHAR(1024) default "";
  Declare xx VARCHAR(1024) default "";
  Declare yy VARCHAR(1024) default "";
  Select fn_tb_water_mth_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into test_txt;
  Select length(test_txt) into test_txt_len;
  Select fn_tb_water_mth_concat_x(in_fr_dt, in_to_dt) into xx;
  Select fn_tb_water_mth_concat_y_one(in_fr_dt, in_to_dt,in_dept_code) into yy;
  if test_txt_len < 2 then
     set out_x = '{"data":null,"code":1}';
  else
     set out_x = concat( '{"data":{"xAxisData":[', xx , '],"deptvalue":{', yy, ']}},"code":1}');
   end if;
   return out_x;
End */$$
DELIMITER ;

/* Function  structure for function  `func_get_split_string` */

/*!50003 DROP FUNCTION IF EXISTS `func_get_split_string` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `func_get_split_string`(

f_string varchar(1000),f_delimiter varchar(5),f_order int) RETURNS varchar(255) CHARSET utf8
BEGIN

 declare result varchar(255) default '';

 set result = reverse(substring_index(reverse(substring_index(f_string,f_delimiter,f_order)),f_delimiter,1));

 return result;

END */$$
DELIMITER ;

/* Function  structure for function  `func_get_split_string_total` */

/*!50003 DROP FUNCTION IF EXISTS `func_get_split_string_total` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `func_get_split_string_total`(

f_string varchar(1000),f_delimiter varchar(5)

) RETURNS int(11)
BEGIN

 return 1+(length(f_string) - length(replace(f_string,f_delimiter,'')));

END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_print_result` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_print_result` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `sp_print_result`(
 IN f_string varchar(1000),IN f_delimiter varchar(5)
)
BEGIN
 declare cnt int default 0;
 declare i int default 0;
 set cnt = func_get_split_string_total(f_string,f_delimiter);
 drop table if exists tmp_print;
 create temporary table tmp_print (num int not null);
 while i < cnt
 do
  set i = i + 1;
  insert into tmp_print(num) values (func_get_split_string(f_string,f_delimiter,i));
 end while;
 select * from tmp_print;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tb_elec_update_inc_val` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tb_elec_update_inc_val` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `sp_tb_elec_update_inc_val`( )
BEGIN
DECLARE temp_id int(10);
DECLARE temp_dt_tm datetime;
declare temp_value int(8);
declare temp_prev_value int(8);
declare temp_location varchar(30);
declare temp_inc_value int(8);
declare done int;
declare cur1 cursor for select id, dt_tm, value, location from TB_ELEC where inc_value is null and dt_tm is not null order by dt_tm asc;
declare continue handler for not found set done =1;
    set done = 0;
    open cur1;
    igmLoop: loop
        fetch cur1 into temp_id,temp_dt_tm,temp_value,temp_location;
set temp_prev_value = temp_value;
Select value into temp_prev_value from TB_ELEC where location=temp_location and dt_tm < temp_dt_tm order by dt_tm desc limit 1;
Select  temp_value - temp_prev_value into temp_inc_value;
update TB_ELEC set inc_value=temp_inc_value where id=temp_id;
        if done = 1 then leave igmLoop; 
        end if;
    end loop igmLoop;
    close cur1;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tb_elec_update_inc_val_loop` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tb_elec_update_inc_val_loop` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `sp_tb_elec_update_inc_val_loop`( )
BEGIN
DECLARE counter int(10);
select count(*) into counter from TB_ELEC where inc_value is null and dt_tm is not null order by dt_tm asc;
while counter > 0 DO
  Call sp_tb_elec_update_inc_val();
  select count(*) into counter from TB_ELEC where inc_value is null and dt_tm is not null order by dt_tm asc;
end while;
end */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
