<h1>How to Retrieve the Data</h1>

<p>This guide provides all the steps in order to use the European Social Survey (ESS) dataset. Follow the instructions below to obtain the data in <code>.csv</code> format and, if needed, this tutorial will show you how to convert it to <code>SAS</code>.</p>

<h2>Step 1: Download the ESS Data in .csv Format</h2>

<ol>
    <li>Navigate to the <a href="https://www.europeansocialsurvey.org/data/" target="_blank">European Social Survey Data Page</a>.</li>
    <li>Under the “Data” section, locate the survey for the year 2012 (ESS Round 6).</li>
    <li>Go to “Data Files” then select the file labeled “ESS6-integrated-Data file, edition 2.6”.</li>
    <li>Click “Login to download data”.</li>
    <li>Log in with your Google account or use one of the other options available.</li>
    <li>Select the file in <code>.csv</code> format from the available download options (sav, dta, csv).</li>
</ol>

<h2>Step 2: Convert the Data to SAS Format (Optional)</h2>

<p>For users who need the data in SAS format, follow these steps:</p>

<pre><code>PROC IMPORT DATAFILE = 'YOUR_PATH/ESS6e02_6.csv'
    OUT = work.ess
    DBMS = CSV replace;
    GUESSINGROWS = MAX;
    GETNAMES = YES;
RUN;
</code></pre>

<p>To verify the import, you may add:</p>

<pre>
PROC FREQ DATA = ESS;
TABLE cntry;
RUN;
</pre>

<p>Upon successful import, SAS will confirm with the following log message:</p>

<blockquote>
NOTE: WORK.ESS data set was successfully created.<br>
NOTE: The data set WORK.ESS has 54,673 observations and 625 variables.
</blockquote>

<p>By default, SAS saves the table in the temporary WORK.ESS library.</p>

<h2>Now, your dataset should be ready to be used!</h2>
