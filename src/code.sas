/* Exportation of figures to svg format and tables in LaTeX */
ODS LISTING GPATH= "/home/u64093709/sas";
ODS GRAPHICS / RESET=all OUTPUTFMT=svg IMAGENAME='figure' NOBORDER NOIMAGEMAP;
ODS LATEX FILE="/home/u64093709/sas/tables.tex";
ODS NOPROCTITLE;

/* Important note: no TITLE command will be used here as they will be 
directly implemented in SAS. Additionally, some graphics will be 
redrawn in LaTeX after receiving data from the SAS code*/

/* Importation of ESS data */
PROC IMPORT DATAFILE= "/home/u64093709/sas/ESS6e02_6.csv"
/* into the ESS6 table of the working library */
	OUT= work.ess
	DBMS= CSV
	REPLACE;
	GUESSINGROWS = MAX; /* This option is required to avoid format errors
	on certain variables. However, the program will take longer to run */
	GETNAMES=YES;
RUN;

/* ENSAE color used in accordance with the thesis */
%let col_ensae = CXFF0000;
%let col_ensae_bis = CX8B0000;

/* Creation of a working library containing only French observations */
DATA work.essfr;
	SET work.ess;
	WHERE cntry eq "FR"; /* condition applied using the 'cntry' variable */
RUN;

/* Search for the variables in the database and their characteristics */
PROC CONTENTS DATA = work.ess;
RUN;

/* Creation of a variable that segments the population by age group */
DATA work.essfr;
	SET work.essfr;
	LENGTH tranche_dage $30;
	LABEL tranche_dage  = "Age group";
	IF 15<= agea <= 24 THEN tranche_dage = "15-24 years";
	ELSE IF 25<= agea <= 49 THEN tranche_dage = "25-49 years";
	ELSE IF 50<= agea THEN tranche_dage = "Over 50 years";
RUN;

/* Reformatting of the gender variable */
PROC FORMAT;
	VALUE genre
	1 = "Men"
	2 = "Women";
RUN;

/* Creation of a variable describing the individual's marital status */
DATA work.essfr;
	SET work.essfr;
	LENGTH cpl $30;
	LABEL cpl = "Marital status";
	IF 1<= rshpsts <=2 THEN cpl = "Married/Civil union";
	ELSE IF 3<= rshpsts <=4 THEN cpl = "In a couple";
	ELSE IF 5<= rshpsts <=6 THEN cpl = "Separated/Divorced";
RUN;

/* Reformatting of the variable indicating working hours according to 
French hourly contract norms: full-time and part-time */
DATA work.essfr;
	SET work.essfr;
	LENGTH tps $30;
	LABEL tps = "Work regime";
	IF wkhct <= 34 THEN tps = "Part-time";
	ELSE IF wkhct >= 35 THEN tps = "Full-time";
RUN;

/* Reformatting of the variable indicating the highest level of education 
with a reduced number of categories, while reflecting the proportions 
of individuals in each category */
DATA work.essfr;
	SET work.essfr;
	LENGTH diplome $50;
	LABEL diplome = "Highest level of education";
	IF 1<= edlvdfr <=5 THEN diplome = "Certificate or less";
	ELSE IF 6<= edlvdfr <=12 THEN diplome = "Baccalaureate or equivalent";
	ELSE IF 13<= edlvdfr <=16 THEN diplome = "Bac + 2";
	ELSE IF 17<= edlvdfr <=18 THEN diplome = "Bachelor's degree or equivalent";
	ELSE IF 19<= edlvdfr <=24 THEN diplome = "Master's degree or equivalent";
	ELSE IF 25<= edlvdfr <=26 THEN diplome = "Doctorate or equivalent";
RUN;
	
/* Conversion of the isco08 variable into socioprofessional categories as 
defined by the nomenclature (PCS). Unfortunately, there is no direct way
to transfer from one nomenclature to another, so it has to be done manually 
based on the definitions of each group from the INSEE website (see Annexes) */
DATA work.essfr;
	SET work.essfr;
	LENGTH categorie_sociopro $50;
	LABEL categorie_sociopro = "Socioprofessional category";
	IF 6000<= isco08 <=6340 THEN categorie_sociopro = "Farmers";
	ELSE IF 1400<= isco08 <=1450 OR 5161<= isco08 <=5169 OR 5200<= isco08 <=5249 
	OR 7300<= isco08 <=7323 OR 7511<= isco08 <=7513 OR isco08=7516 OR 
	7531<= isco08 <=7549 OR 9500<= isco08 <=9520 
	THEN categorie_sociopro = "Artisans, merchants, and business owners";
	ELSE IF 1100<= isco08 <=1350 OR 2100<= isco08 <=2643 OR 100<= isco08 <=110
	THEN categorie_sociopro = "Executives and intellectual professions";
	ELSE IF 3100<=isco08<=3522 
	THEN categorie_sociopro = "Intermediate professions";
	ELSE IF 4000<= isco08 <=4419 or 9200<= isco08<= 9216 OR 5100<= isco08 <=5113
	OR 5130<= isco08 <=5160 OR 5300<= isco08 <=5419 OR 9100<= isco08 <=9129 OR
	9400<= isco08 <=9412 OR 200<= isco08 <=310 
	THEN categorie_sociopro = "Employees";
	ELSE IF 8000<= isco08 <=8350 OR 7100<= isco08 <=7234 OR 7400<= isco08 <=7422 OR
	7500<= isco08 <=7510 OR 7514<= isco08 <=7515 OR 7520<= isco08 <=7530 OR 9300<= isco08 <=9334
	OR 9600<= isco08 <=9629 OR isco08=5120 THEN categorie_sociopro = "Workers";
RUN;

/* Verification of the implementation of new variables in the database */
PROC CONTENTS DATA = work.essfr;
RUN;

PROC GCHART DATA = work.essfr;
	PIE categorie_sociopro / FREQ= anweight PERCENT= arrow;
RUN;
QUIT;

/* Table cross-referencing the two variables tranche_dage and categorie_sociopro 
to determine the height for each bar segment */
PROC FREQ DATA = work.essfr;
	WHERE categorie_sociopro NE '';
    TABLES tranche_dage*categorie_sociopro /OUT= frequence_age 
    OUTPCT NOROW NOCOL NOFREQ MISSING;
    WEIGHT anweight;
RUN;

/* In LaTeX, the percentages were redefined so that they are not relative to 
the entire labor market but only to the relevant socioprofessional category */
PROC SGPLOT DATA= frequence_age ;
    VBAR categorie_sociopro /RESPONSE=PERCENT GROUP= tranche_dage STAT= sum 
        DATALABEL;  
    YAXIS LABEL="Percentage (%)";  
    TITLE "Distribution of workers by age";
RUN;

/* Univariate procedure to obtain additional information on agea */
PROC UNIVARIATE DATA = work.essfr;
	VAR agea;
	WEIGHT anweight;
RUN;

PROC SGPLOT DATA = work.essfr;
 	HBAR categorie_sociopro / FREQ = anweight GROUP = tps STAT = sum
 		DATALABEL;
 	WHERE tranche_dage = "15-24 years";
RUN;

/* Conversion of the occf14b variable into socioprofessional categories 
as defined by the nomenclature (PCS). Unfortunately, the 9 categories in the survey 
are too broad, leading to an approximate conversion */
DATA work.essfr;
	SET work.essfr;
	LENGTH csp_pere $50;
	LABEL csp_pere = "Father's socioprofessional category";
	IF occf14b = 9 THEN csp_pere = "Farmers";
	ELSE IF occf14b = 4 
	THEN csp_pere = "Artisans, merchants, and business owners";
	ELSE IF 1 <= occf14b <= 2 
	THEN csp_pere = "Executives and intellectual professions";
	ELSE IF occf14b = 7 THEN csp_pere = "Intermediate professions";
	ELSE IF occf14b = 3  OR  occf14b = 5 OR occf14b = 8 THEN csp_pere = "Employees";
	ELSE IF occf14b = 6 THEN csp_pere = "Workers";
RUN;
	
/* Verification that the proportions are in a similar order of magnitude 
to what was observed in the first part */
PROC GCHART DATA = work.essfr;
	PIE csp_pere/ FREQ= anweight PERCENT = arrow;
RUN;
QUIT;

/* Setting an order for the heatmap */
DATA work.essfr;
    SET work.essfr;
    SELECT (categorie_sociopro);
        WHEN ("Farmers") ordre = 1;
        WHEN ("Artisans, merchants, and business owners") ordre = 2;
        WHEN ("Executives and intellectual professions") ordre = 3;
        WHEN ("Intermediate professions") ordre = 4;
        WHEN ("Employees") ordre = 5;
        WHEN ("Workers") ordre = 6;
        OTHERWISE ordre = 7;
    END;
RUN;


