# 📘 README

<h2>🌍 Overview</h2>
<p>This project analyzes the influence of socio-economic factors on professional choices in France. Using data from the European Social Survey (ESS), it explores the impact of factors such as age, social origin, education level, and gender on occupational outcomes. The study relies on statistical methodologies and graphical representations to provide insights into workforce distribution and inequalities.</p>

<h2>📂 Repository Structure</h2>

<h4>📊 <code>data/</code></h4>
<ul>
  <li> Explains how to retrieve the data from the European Social Survey's website (ESS) and convert it so as to make the dataset usable for the analysis. Also shows how to filter it in order to keep observations from France only.</li>
</ul>

<h4>📜 <code>docs/</code></h4>
<ul>
  <li> <code>ESS6_appendix_a6_e01_1.pdf/</code>: appendix describing all the classifications and coding standards used in the ESS survey. Used specifically for converting between ISCO-08 and socio-professional categories (CSP). </li>
  <li> <code>ESS6_appendix_a7_e01_0.pdf/</code>: appendix describing all the parameters and their possible values.</li>
  <li> <code>ESS6_source_main_questionnaire.pdf/</code>: encompasses all the questions asked to the respondents as well as the possible answers.</li>
  <li> <code>ESS_weighting_data_1_2.pdf/</code>: guide to using weights with ESS Data. </li>
</ul>

<h4>📑 <code>report/</code></h4>
<ul>
  <li> Holds the final report summarizing findings and conclusions on the socio-economic determinants of professional choices. It also includes various statistical analyses and visual representations (pie, histogram, heatmap, ...).</li>
</ul>

<h4>🖥️ <code>src/</code></h4>
<ul>
  <li>Contains the SAS script handling variable transformations, statistical modeling, and graphical representation of results.</li>
</ul>

<h2>✨ Notes</h2>
<p>All graphs and figures in the report were generated using LaTeX for a polished and structured presentation.</p>
