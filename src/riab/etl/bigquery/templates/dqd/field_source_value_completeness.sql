/*********
SOURCE_VALUE_COMPLETENESS
number of source values with 0 standard concept / number of distinct source values

Parameters used in this template:
cdmDatabaseSchema = @cdmDatabaseSchema
cdmTableName = @cdmTableName
cdmFieldName = @cdmFieldName
standardConceptFieldName = @standardConceptFieldName
{@cohort & '@runForCohort' == 'Yes'}?{
cohortDefinitionId = @cohortDefinitionId
cohortDatabaseSchema = @cohortDatabaseSchema
}
**********/

SELECT num_violated_rows, CASE WHEN denominator.num_rows = 0 THEN 0 ELSE 1.0*num_violated_rows/denominator.num_rows END  AS pct_violated_rows, 
  denominator.num_rows as num_denominator_rows
FROM
(
	SELECT COUNT_BIG(violated_rows.violating_field) AS num_violated_rows
	FROM
	(
		SELECT DISTINCT '@cdmTableName.@cdmFieldName' AS violating_field, cdmTable.@cdmFieldName
		FROM @cdmDatabaseSchema.@cdmTableName cdmTable
		{@cohort & '@runForCohort' == 'Yes'}?{
    	JOIN @cohortDatabaseSchema.COHORT c 
    	ON cdmTable.PERSON_ID = c.SUBJECT_ID
    	AND c.COHORT_DEFINITION_ID = @cohortDefinitionId
    	}
		WHERE cdmTable.@standardConceptFieldName = 0
	) violated_rows
) violated_row_count,
( 
	SELECT COUNT_BIG(distinct cdmTable.@cdmFieldName) + COUNT(DISTINCT CASE WHEN cdmTable.@cdmFieldName IS NULL THEN 1 END)  AS num_rows
	FROM @cdmDatabaseSchema.@cdmTableName cdmTable
	{@cohort & '@runForCohort' == 'Yes'}?{
    	JOIN @cohortDatabaseSchema.COHORT c 
    	ON cdmTable.PERSON_ID = c.SUBJECT_ID
    	AND c.COHORT_DEFINITION_ID = @cohortDefinitionId
    	}
) denominator
;
