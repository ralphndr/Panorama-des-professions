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

/* Verification that the proportions are in a similar order of magnitude 
close to what was observed in the first part */
PROC GCHART DATA = work.essfr;
	PIE csp_pere / FREQ= anweight PERCENT = arrow;
RUN;
QUIT;

/* Setting up an order for the heatmap */
DATA work.essfr;
    SET work.essfr;
    SELECT (categorie_sociopro);
        WHEN ("Farmers") ordre = 1;
        WHEN ("Artisans, merchants, and business owners") ordre = 2;
        WHEN ("Executives and intellectual professions") ordre = 3;
        WHEN ("Employees") ordre = 4;
        WHEN ("Workers") ordre = 5;
        WHEN ("Intermediate professions") ordre = 6;
        OTHERWISE ordre = .; /* For unspecified categories */
    END;
RUN;

/* Sorting the socioprofessional category variable according to the established order */
PROC SORT DATA= work.essfr;
    BY ordre;
RUN;

/* Setting up an order for the heatmap */
DATA work.essfr;
    SET work.essfr;
    SELECT(csp_pere);
        WHEN ("Farmers") ordre_pere = 1;
        WHEN ("Artisans, merchants, and business owners") ordre_pere = 2;
        WHEN ("Executives and intellectual professions") ordre_pere = 3;
        WHEN ("Employees") ordre_pere = 4;
        WHEN ("Workers") ordre_pere = 5;
        WHEN ("Intermediate professions") ordre_pere = 6;
        OTHERWISE ordre_pere = .; /* For unspecified categories */
    END;
RUN;

/* Sorting the father's socioprofessional category variable according to the selected order */
PROC SORT DATA= work.essfr;
    BY ordre_pere;
RUN;


/* Heatmap of the father's socioprofessional category relative to the child's */
PROC SGPLOT DATA = work.essfr;
	HEATMAP X = categorie_sociopro Y = csp_pere / FREQ = anweight
	COLORSTAT = PCT /* Analysis weight in % */
	/* Different aesthetic adjustments */
	COLORMODEL = (white &col_ensae) DISCRETEX DISCRETEY;
	XAXIS 
	LABEL= "Child's Socioprofessional Category";
	YAXIS 
	LABEL= "Father's Socioprofessional Category"
	DISCRETEORDER = FORMATTED;
RUN;

/* Table giving the percentages for each cell of the heatmap */
PROC FREQ DATA=work.essfr;
	WEIGHT anweight;
    TABLES categorie_sociopro*csp_pere / OUT=heatmap_freq OUTPCT NOPRINT;
RUN;

/* The same process for the mother */
DATA work.essfr;
	SET work.essfr;
	LENGTH csp_mere $50;
	LABEL csp_mere = "Mother's Socioprofessional Category";
	IF occm14b = 9 THEN csp_mere = "Farmers";
	ELSE IF occm14b = 4 
	THEN csp_mere = "Artisans, merchants, and business owners";
	ELSE IF 1 <= occm14b <= 2 
	THEN csp_mere = "Executives and intellectual professions";
	ELSE IF occm14b = 7 THEN csp_mere = "Intermediate professions";
	ELSE IF occm14b = 3  OR  occm14b = 5 OR occm14b = 8 THEN csp_mere = "Employees";
	ELSE IF occm14b = 6 THEN csp_mere = "Workers";
RUN;

PROC GCHART DATA = work.essfr;
	PIE csp_mere / FREQ= anweight PERCENT = arrow;
RUN;
QUIT;

DATA work.essfr;
    SET work.essfr;
    SELECT (categorie_sociopro);
        WHEN ("Farmers") ordre = 1;
        WHEN ("Artisans, merchants, and business owners") ordre = 2;
        WHEN ("Executives and intellectual professions") ordre = 3;
        WHEN ("Employees") ordre = 4;
        WHEN ("Workers") ordre = 5;
        WHEN ("Intermediate professions") ordre = 6;
        OTHERWISE ordre = .; /* For unspecified categories */
    END;
RUN;

PROC SORT DATA= work.essfr;
    BY ordre;
RUN;

DATA work.essfr;
    SET work.essfr;
    SELECT(csp_mere);
        WHEN ("Farmers") ordre_mere = 1;
        WHEN ("Artisans, merchants, and business owners") ordre_mere = 2;
        WHEN ("Executives and intellectual professions") ordre_mere = 3;
        WHEN ("Employees") ordre_mere = 4;
        WHEN ("Workers") ordre_mere = 5;
        WHEN ("Intermediate professions") ordre_mere = 6;
        OTHERWISE ordre_mere = .; /* For unspecified categories */
    END;
RUN;

PROC SORT DATA= work.essfr;
    BY ordre_mere;
RUN;

PROC SGPLOT DATA = work.essfr;
	HEATMAP X = categorie_sociopro Y = csp_mere / FREQ = anweight
	COLORSTAT = PCT /* Analysis weight in % */
	/* Different aesthetic adjustments */
	COLORMODEL = (white &col_ensae) DISCRETEX DISCRETEY;
	XAXIS 
	LABEL= "Child's Socioprofessional Category";
	YAXIS 
	LABEL= "Mother's Socioprofessional Category"
	DISCRETEORDER = FORMATTED;
RUN;

PROC FREQ DATA=work.essfr;
	WEIGHT anweight;
    TABLES categorie_sociopro*csp_mere / OUT=heatmap_freq OUTPCT NOPRINT;
RUN;

/* Parents' level of education */
DATA work.essfr;
	SET work.essfr;
	LENGTH niveau_pere 5;
	LABEL niveau_pere = "Father's Highest Education Level";
	IF 1 <= edlvfdfr <= 5 THEN niveau_pere = 1;
	ELSE IF 6 <= edlvfdfr <= 12 THEN niveau_pere = 2;
	ELSE IF 13 <= edlvfdfr <= 16 THEN niveau_pere = 3;
	ELSE IF 17 <= edlvfdfr <= 18 THEN niveau_pere = 4;
	ELSE IF 19 <= edlvfdfr <= 24 THEN niveau_pere = 5;
	ELSE IF 25 <= edlvfdfr <= 26 THEN niveau_pere = 6;
RUN;

DATA work.essfr;
	SET work.essfr;
	LENGTH niveau_mere 8;
	LABEL niveau_mere = "Mother's Highest Education Level";
	IF 1 <= edlvmdfr <= 5 THEN niveau_mere = 1;
	ELSE IF 6 <= edlvmdfr <= 12 THEN niveau_mere = 2;
	ELSE IF 13 <= edlvmdfr <= 16 THEN niveau_mere = 3;
	ELSE IF 17 <= edlvmdfr <= 18 THEN niveau_mere = 4;
	ELSE IF 19 <= edlvmdfr <= 24 THEN niveau_mere = 5;
	ELSE IF 25 <= edlvmdfr <= 26 THEN niveau_mere = 6;
RUN;

DATA work.essfr;
	SET work.essfr;
	LENGTH niveau 8;
	LABEL niveau = "Individual's Highest Education Level";
	IF 1 <= edlvdfr <= 5 THEN niveau = 1;
	ELSE IF 6 <= edlvdfr <= 12 THEN niveau = 2;
	ELSE IF 13 <= edlvdfr <= 16 THEN niveau = 3;
	ELSE IF 17 <= edlvdfr <= 18 THEN niveau = 4;
	ELSE IF 19 <= edlvdfr <= 24 THEN niveau = 5;
	ELSE IF 25 <= edlvdfr <= 26 THEN niveau = 6;
RUN;

/* Comparison of education levels of parents and their child */
DATA niveau_deducation;
    SET work.essfr;
    LENGTH role $10 nv 8;
    role = "Individual"; nv = niveau; OUTPUT;
    role = "Mother";     nv = niveau_mere; OUTPUT;
    role = "Father";     nv = niveau_pere; OUTPUT;
RUN;

PROC FREQ DATA= niveau_deducation NOPRINT;
    TABLES role*nv / OUT=freq_data; 
RUN;

/* Joining the two tables */
PROC SQL;
    CREATE TABLE freq_data_pct AS
    SELECT a.*, 
           (a.count / b.total) * 100 AS percentage
    FROM freq_data AS a
    LEFT JOIN (
        SELECT role, SUM(count) AS total
        FROM freq_data
        GROUP BY role
    ) AS b
    ON a.role = b.role;
QUIT;

/* Verifying the content */
PROC FREQ data = freq_data_pct;
RUN;

/* Bar chart grouped by 3 */
PROC SGPLOT DATA= freq_data_pct;
    VBAR nv / RESPONSE= percentage GROUP=role GROUPDISPLAY=cluster;
    XAXIS LABEL="Highest Education Level";
    YAXIS LABEL="Frequency";
    KEYLEGEND / POSITION= right;
RUN;

/* Creation of pie charts for the 3 categories: CPIS, PI, and Employees */
PROC GCHART DATA = work.essfr;
	WHERE categorie_sociopro = "Employees";
	PIE diplome / FREQ= anweight PERCENT= arrow;
RUN;
QUIT;

PROC GCHART DATA = work.essfr;
	WHERE categorie_sociopro = "Executives and intellectual professions";
	PIE diplome / FREQ= anweight PERCENT= arrow;
RUN;
QUIT;

/* Professions intermédiaires - Pie chart by 'diplome' for a specific socio-professional category */
PROC GCHART DATA = work.essfr;
	WHERE categorie_sociopro = "Intermediary professions";
	PIE diplome / FREQ= anweight PERCENT= arrow;
RUN;
QUIT;

/* Digital version for a readable graph */
DATA work.essfr;
    SET work.essfr;
    LENGTH csp $30;
    LABEL csp = "Socioprofessional category (numeric)";
    
    IF categorie_sociopro = "Farmers" THEN csp = "1";
    ELSE IF categorie_sociopro = "Artisans, merchants, and business owners" 
    THEN csp = "2";
    ELSE IF categorie_sociopro = "Executives and intellectual professions" 
    THEN csp = "3";
    ELSE IF categorie_sociopro = "Employees" THEN csp = "4";
    ELSE IF categorie_sociopro = "Workers" THEN csp = "5";
    ELSE IF categorie_sociopro = "Intermediary professions" THEN csp = "6";
RUN;


/* Calculate the total weights by gender */
PROC SQL;
    CREATE TABLE work.total_per_gender AS
    SELECT 
        gndr, 
        SUM(anweight) AS total_weight
    FROM work.essfr
    GROUP BY gndr;
QUIT;

/* Sorting data */
PROC SORT DATA=work.essfr OUT=work.essfr_sorted;
    BY gndr;
RUN;

PROC SORT DATA=work.total_per_gender OUT=work.total_per_gender_sorted;
    BY gndr;
RUN;

/* Merging the sorted data */
DATA work.essfr_with_pct;
    MERGE work.essfr_sorted(IN=a) work.total_per_gender_sorted(IN=b);
    BY gndr;
    IF a AND b; /* Keep only matched records */
    pct_within_gender = (anweight / total_weight) * 100;
RUN;

/* Horizontal bar chart showing percentage of CSP by gender */
PROC GCHART DATA=work.essfr_with_pct;
    HBAR csp / SUMVAR=pct_within_gender TYPE=SUM GROUP=gndr;
    FORMAT gndr genre.;
    TITLE "Percentage distribution of socio-professional categories (CSP) by gender";
RUN;
QUIT;

/* Volume horaire distribution by gender */
PROC FREQ DATA=work.essfr;
    TABLES tps gndr;
RUN;

/* Calculate the total weights by gender again */
PROC SQL;
    CREATE TABLE work.total_per_gender AS
    SELECT gndr, SUM(anweight) AS total_weight
    FROM work.essfr
    GROUP BY gndr;
QUIT;

/* Calculate percentages for each gender and time spent category */
PROC SQL;
    CREATE TABLE work.freq_tps_gndr_pct AS
    SELECT a.gndr, 
           a.tps, 
           SUM(a.anweight) AS total_weight_tps, 
           (SUM(a.anweight) / b.total_weight) * 100 AS pct_within_gender
    FROM work.essfr AS a
    INNER JOIN work.total_per_gender AS b
    ON a.gndr = b.gndr
    GROUP BY a.gndr, a.tps, b.total_weight;
QUIT;

/* Create a bar chart for time spent distribution by gender */
PROC GCHART DATA=work.freq_tps_gndr_pct;
    VBAR gndr / SUBGROUP=tps SUMVAR=pct_within_gender 
                 TYPE=SUM 
                 DISCRETE 
                 OUTSIDE=SUM; /* Shows the percentages above each bar */
    FORMAT gndr genre. tps $20.;
    TITLE "Time spent distribution by gender";
RUN;
QUIT;

/* Pie chart for housework in the past 7 days for each gender */
PROC GCHART DATA=work.essfr;
    PIE hswrk / FREQ = anweight PERCENT = arrow;
    WHERE gndr = 1; /* Men */
RUN;
QUIT;

PROC GCHART DATA=work.essfr;
    PIE hswrk / FREQ = anweight PERCENT = arrow;
    WHERE gndr = 2; /* Women */
RUN;
QUIT;

/* Filter data for women and specific CSP categories (3 or 4) */
DATA filtered_data;
    SET work.essfr;
    IF gndr = 2 and (csp = "3" or csp = "4");
RUN;

/* Sort the filtered data */
PROC SORT DATA=filtered_data;
    BY csp cpl;
RUN;

/* Calculate frequencies for each marital status by CSP */
PROC FREQ DATA=filtered_data NOPRINT;
    TABLES cpl*csp / OUT=freq_out;
    WHERE csp in ("3", "4");
RUN;

/* Sort frequencies output */
PROC SORT DATA=freq_out;
    BY csp cpl;
RUN;

/* Calculate percentage for each marital status per CSP */
DATA perc_data;
    SET freq_out;
    BY csp;
    
    /* Calculate total count for each CSP */
    IF first.csp THEN total_count = 0;
    total_count + count;
    
    /* Calculate percentage for each marital status */
    percentage = (count / total_count) * 100;
    
    /* Keep all marital status categories */
    OUTPUT;
RUN;

/* Bar chart showing the influence of marital status on women's profession */
PROC SGPLOT DATA=perc_data;
    VBAR cpl / RESPONSE=percentage STAT=sum GROUP=csp GROUPDISPLAY=cluster;
    XAXIS LABEL='Marital status';
    YAXIS LABEL='Percentage' GRID;
    TITLE "Influence of a woman's marital status on her profession";
RUN;

/* Calculate the total weights by time spent category for women */
PROC SQL;
    CREATE TABLE work.total_per_tps AS
    SELECT 
        tps, 
        SUM(anweight) AS total_weight
    FROM work.essfr
    WHERE gndr = 2 /* Women only */
    GROUP BY tps;
QUIT;

/* Sort data for women */
PROC SORT DATA=work.essfr OUT=work.essfr_sorted;
    BY tps;
RUN;

PROC SORT DATA=work.total_per_tps OUT=work.total_per_tps_sorted;
    BY tps;
RUN;

/* Merge data sorted for women */
DATA work.essfr_with_pct;
    MERGE work.essfr_sorted(IN=a) work.total_per_tps_sorted(IN=b);
    BY tps;
    IF a AND b AND gndr = 2; /* Keep only matched records for women */
    pct_within_tps = (anweight / total_weight) * 100;
RUN;

/* Horizontal bar chart for women's time spent distribution with children at home or not */
PROC GCHART DATA=work.essfr_with_pct;
    HBAR tps / SUMVAR=pct_within_tps TYPE=SUM GROUP=chldhm;
    TITLE "Distribution in % of working hours based on the presence of children at home or not - for women";
RUN;
QUIT;



