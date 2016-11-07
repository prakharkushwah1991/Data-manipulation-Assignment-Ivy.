*Working Directory;
libname wd '/folders/myfolders';

/*Import the datasets*/
*CWURDATA;
data WD.CWURDATA;
	infile '/folders/myfolders/cwurdata.csv' delimiter = ',' MISSOVER DSD  firstobs=2 ;
	informat world_rank $10. ;
	informat institution $49. ;
	informat country $14. ;
	informat national_rank best32. ;
	informat quality_of_education best32. ;
	informat alumni_employment best32. ;
	informat quality_of_faculty best32. ;
	informat publications best32. ;
	informat influence best32. ;
	informat citations best32. ;
	informat broad_impact $1. ;
	informat patents best32. ;
	informat score best32. ;
	informat year best32. ;	
	format world_rank $10. ;
	format institution $49. ;
	format country $14. ;
	format national_rank best12. ;
	format quality_of_education best12. ;
 	format alumni_employment best12. ;
	format quality_of_faculty best12. ;
	format publications best12. ;
	format influence best12. ;
 	format citations best12. ;
	format broad_impact $1. ;
	format patents best12. ;
	format score best12. ;
	format year best12. ;
	input
		world_rank $
		institution $
		country $
		national_rank
		quality_of_education
		alumni_employment
		quality_of_faculty
		publications
		influence
		citations
		broad_impact $
		patents
		score
		year
	;
 run;

*SHANGHAIDATA;
data WD.SHANGHAIDATA;
	infile '/folders/myfolders/shanghaidata.csv' delimiter = ',' MISSOVER DSD  firstobs=2 ;
	informat world_rank $10. ;
	informat university_name $43. ;
	informat national_rank $10. ;
	informat total_score best32. ;
	informat alumni best32. ;
	informat award best32. ;
	informat hici best32. ;
	informat ns best32. ;
	informat pub best32. ;
	informat pcp best32. ;
	informat year best32. ;
	format world_rank $10. ;
	format university_name $43. ;
	format national_rank $10. ;
	format total_score best12. ;
	format alumni best12. ;
	format award best12. ;
	format hici best12. ;
	format ns best12. ;
	format pub best12. ;
	format pcp best12. ;
	format year best12. ;
	input
		world_rank $
		university_name $
		national_rank $
		total_score
		alumni
		award
		hici
		ns
		pub
		pcp
		year
	;
run;

*TIMESDATA;
data WD.TIMESDATA;
	infile '/folders/myfolders/timesdata.csv' delimiter = ',' MISSOVER DSD  firstobs=2 ;
	informat world_rank $10. ;
	informat university_name $59. ;	
	informat country $24. ;
	informat teaching best32. ;
	informat international best32. ;
	informat research best32. ;
	informat citations best32. ;
 	informat income best32. ;
	informat total_score best32. ;
	informat num_students comma10. ;
	informat student_staff_ratio best32. ;
	informat international_students $3. ;
	informat female_male_ratio $7. ;
	informat year best32. ;
	format world_rank $10. ;
 	format university_name $59. ;
	format country $24. ;
	format teaching best12. ;
 	format international best12. ;
 	format research best12. ;
	format citations best12. ;
	format income best12. ;
	format total_score best12. ;	
	format num_students comma10. ;
	format student_staff_ratio best12. ;
 	format international_students $3. ;
	format female_male_ratio $7. ;
	format year best12. ;
	input	
		world_rank $
 		university_name $
 		country $
 		teaching
 		international
		research
		citations
		income
		total_score
		num_students
		student_staff_ratio
		international_students $
		female_male_ratio $
		year
	;
run;

*Section 1;
*Q0;
data wd.timesdata;
	set wd.timesdata;
	international_students = compress(international_students,'0123456789.','k');
	international_students = input(international_students, best12.);
	international_students = international_students / 100;
run;

data wd.timesdata;
	set wd.timesdata;
	female_proportion = input(scan(female_male_ratio, 1, ':'), best12.);
	male_proportion = input(scan(female_male_ratio, 2, ':'), best12.);
	drop female_male_ratio;
run;

*Q1;
proc freq data=wd.timesdata;
	table year;
run;

data wd.timesdata_top10;
	set wd.timesdata;
	if world_rank in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10');
run;

*Q2;
proc freq data=wd.timesdata;
	table country;
run;

data wd.timesdata_america;
	set wd.timesdata;
	if country in ('United States of America', 'Unisted States of Americ');
run;

*Q3;
data wd.timesdata;
	set wd.timesdata;
	country_year = catx(':', country, year);
run;

proc sort data=wd.timesdata out=wd.timesdata_numstud;
	by country_year descending num_students;
run;

data wd.timesdata_numstud_top;
	set wd.timesdata_numstud;
	by country_year;
	if first.country_year;
run;

*Q4;
proc sort data=wd.timesdata out=wd.timesdata_top_indian;
	by world_rank;
	where country = 'India';
run;

*Q5;
data wd.timesdata;
	set wd.timesdata;
	world_rank_num = input(world_rank, best12.);
	top25 = 0;
	if world_rank_num in (1:25) then top25 = 1;
run;

proc summary data=wd.timesdata(where=(top25=1));
	class university_name;
	output out=wd.timesdata_top25_freq;
run;

proc print data=wd.timesdata_top25_freq;
	where _FREQ_ > 3 and _TYPE_ = 1;
run;

*Q6;
proc freq data=wd.timesdata(where=(world_rank_num in (1:100)));
	table university_name / out=wd.timesdata_uni_freq;
run;

*Section 2;
*Q0;
proc sort data=wd.timesdata(keep=university_name country) out=wd.university_country_map nodupkey;
	by university_name;
run;

*Q1;
data wd.shanghaidata;
	set wd.shanghaidata;
	world_rank_num = input(world_rank, best12.);
run;

proc sql;
	create table wd.shanghaidata_1 as
	select a.*, b.country from wd.shanghaidata(where=(world_rank_num in (1:100))) as a left join
	wd.university_country_map as b on a.university_name = b.university_name;
quit;
run;

*Q2;
data wd.shanghaidata_1;
	set wd.shanghaidata_1;
	previous_year = year - 1;
	if university_name = '' then delete;
run;

proc means data=wd.shanghaidata_1;
	class university_name;
	var total_score;
	output out=wd.shanghaidata_uni_avgscore MEAN=Average;
run;

data wd.shanghaidata_lag_year;
	set wd.shanghaidata_1;
	keep university_name year total_score;
run;

proc sql;
	create table wd.shanghaidata_1 as
	select a.*, b.total_score as total_score_previous_year from wd.shanghaidata_1 as a left join
	wd.shanghaidata_lag_year as b on (a.university_name = b.university_name and
	a.previous_year = b.year);
quit;
run;

proc sql;
	create table wd.shanghaidata_1 as
	select a.*, b.Average as average_total_score from wd.shanghaidata_1 as a left join
	wd.shanghaidata_uni_avgscore(where=(_TYPE_=1)) as b on a.university_name = b.university_name;
quit;
run;

*Q3;
proc sort data=wd.shanghaidata_1(keep=university_name country average_total_score)
	out=wd.shanghaidata_avg_score_rank nodupkey;
	by university_name;
run;

proc rank data=wd.shanghaidata_avg_score_rank out=wd.shanghaidata_avg_score_rank descending;
	var average_total_score;
	ranks avg_score_rank;
run;

*Q4;
proc sql;
	create table wd.shanghaidata_1 as
	select a.*, b.avg_score_rank from wd.shanghaidata_1 as a left join
	wd.shanghaidata_avg_score_rank as b on a.university_name = b.university_name;
run;

*Q5;
proc transpose data=wd.shanghaidata_1 out=wd.shanghaidata_trans prefix=total_score;
	by university_name;
	id year;
	var total_score;
run;

*Q6;
proc sort data=wd.shanghaidata_1 out=wd.shanghaidata_1_sorted;
	by university_name year;
run;

data wd.shanghaidata_1_sorted_1;
	set wd.shanghaidata_1_sorted;
	by university_name;
	if last.university_name then year_1 = 'latest_year';
	if first.university_name then year_1 = 'first_year';
	if first.university_name or last.university_name;
run;

proc transpose data=wd.shanghaidata_1_sorted_1 out=wd.shanghaidata_rank_change;
	by university_name;
	id year_1;
	var world_rank;
run;

data wd.shanghaidata_rank_change;
	set wd.shanghaidata_rank_change;
	rank_change = latest_year - first_year;
run;

*Section 3;
*Q0;
data wd.combined_scores(keep=institution year cwurdata_score);
	set wd.cwurdata;
	where year in (2012:2015);
	rename score=cwurdata_score;
run;

proc sql;
	create table wd.combined_scores_1 as
	select a.*, b.total_score as timesdata_score from wd.combined_scores as a left join
	wd.timesdata as b on (a.institution = b.university_name and 
	a.year = b.year);
run;

proc sql;
	create table wd.combined_scores_2 as
	select a.*, b.total_score as shanghaidata_score from wd.combined_scores_1 as a left join
	wd.shanghaidata as b on (a.institution = b.university_name and 
	a.year = b.year);
run;

proc datasets lib=wd;
    delete combined_scores combined_scores_1;
quit;

*Q1;
proc sort data=wd.cwurdata out=wd.cwurdata_sorted;
	by institution descending score;
run;

data wd.cwurdata_sorted_deduped;
	set wd.cwurdata_sorted;
	by institution;
	if first.institution;
run;






	






