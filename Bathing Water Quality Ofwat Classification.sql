
CREATE TABLE working_data AS 
	SELECT
	label,
    sampleTime,
	intestinalEnterococciCount,
	log10(intestinalEnterococciCount) AS 'IE LOG10',
	escherichiaColiCount,
	log10(escherichiaColiCount) AS 'EC LOG10'
	FROM samples
	WHERE NOT discountableReason = 'Abnormal Situation' AND  YEAR(sampleTime)>2020;

-- SELECT DISTINCT(discountableReason)
-- FROM samples

ALTER TABLE `site location` CHANGE COLUMN `ï»¿Row Labels` `labels` TEXT;

CREATE TABLE working_data2 AS
SELECT *
FROM (
	SELECT 
		label,
		AVG(`IE LOG10`) mean_ie,
		STDDEV_SAMP(`IE LOG10`) sd_ie,
		POW(10,(AVG(`IE LOG10`)+1.65*STDDEV_SAMP(`IE LOG10`))) AS `95_percentile_ie`,
		POW(10,(AVG(`IE LOG10`)+1.282*STDDEV_SAMP(`IE LOG10`))) AS `90_percentile_ie`,
		AVG(`EC LOG10`) mean_ec, 
		STDDEV_SAMP(`EC LOG10`) sd_ec,
		POW(10,(AVG(`EC LOG10`)+1.65*STDDEV_SAMP(`EC LOG10`))) AS `95_percentile_ec`,
		POW(10,(AVG(`EC LOG10`)+1.282*STDDEV_SAMP(`EC LOG10`))) AS `90_percentile_ec`
		FROM working_data
        -- WHERE label LIKE 'S% North'
        GROUP BY label
    ) AS working_data2
    JOIN `site location` sl
    ON sl.labels = working_data2.label
    ORDER BY label
    ;
    
 #CREATE THE THRESHOLD FOR EXCELLENT, GOOD AND SUFFICIENT DEPENDING ON COASTAL OR INLAND
    
SELECT  IF(`95_percentile_ie` <= IE_excellent AND `90_percentile_ec`<=EC_excellent,"Excellent","Good") AS CLASSIFICATION
FROM
(
	SELECT 
		label, 
		`Location`,  -- Move Location to the second column
		mean_ie, 
		sd_ie, 
		`95_percentile_ie`,
		`90_percentile_ie`,
		mean_ec,
		sd_ec,
		`95_percentile_ec`,
		`90_percentile_ec`,
		IF(Location = "coastal", "100","200") AS IE_excellent,
		IF(Location = "coastal", "200","400") AS IE_good,
		IF(Location = "coastal", "185","330") AS IE_sufficient,
		IF(Location = "coastal", "250","500") AS EC_excellent,
		IF(Location = "coastal", "500","1000") AS EC_good,
		IF(Location = "coastal", "500","900") AS EC_sufficient
	) AS GROUPINGS;
    
    
    CREATE TABLE Ofwat_Classification AS
    WITH GROUPINGS AS (
    SELECT 
        label, 
        `Location`,
        mean_ie, 
        sd_ie, 
        `95_percentile_ie`,
        `90_percentile_ie`,
        mean_ec,
        sd_ec,
        `95_percentile_ec`,
        `90_percentile_ec`,
        IF(Location = "coastal", "100","200") AS IE_excellent,
        IF(Location = "coastal", "200","400") AS IE_good,
        IF(Location = "coastal", "185","330") AS IE_sufficient,
        IF(Location = "coastal", "250","500") AS EC_excellent,
        IF(Location = "coastal", "500","1000") AS EC_good,
        IF(Location = "coastal", "500","900") AS EC_sufficient
	FROM working_data2
)
SELECT  *,
    IF(`95_percentile_ie` <= IE_excellent AND `95_percentile_ec` <= EC_excellent, "Excellent", IF(`95_percentile_ie` <= IE_good AND `95_percentile_ec` <= EC_good, "Good", IF(`90_percentile_ie` <= IE_sufficient AND `90_percentile_ec` <= EC_sufficient, "Sufficient","Poor"))) AS CLASSIFICATION
FROM GROUPINGS;
