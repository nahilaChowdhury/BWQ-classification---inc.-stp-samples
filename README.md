# BWQ-classification---inc.-stp-samples
An SQL script to calculate bathing water classification from sites across England and Wales as "Excellent","Good","Sufficient","Poor". The difference between this classifications and EA's classification is that this analysis includes samples that are taken with short term pollution, whereas EA's doesn't.

Detailed information on pollution risk forecasting, short term pollutions and classification can be found on the EA website: https://environmentagency.blog.gov.uk/2024/02/23/bathing-water-classifications-and-short-term-pollution/

Data can found here and is taken from Jan 2020: https://environment.data.gov.uk/bwq/profiles/data.html

The script cleans, joins and calcualtes to find the classifications. The logic to calculation the classifications can be found here:https://cdr.eionet.europa.eu/help/BWD/Guidelines_for_assessment_under_the_BWD.pdf

Ofwat's performance comittement defintion: https://www.ofwat.gov.uk/wp-content/uploads/2022/12/Bathing_water_quality_PC_definition.pdf
