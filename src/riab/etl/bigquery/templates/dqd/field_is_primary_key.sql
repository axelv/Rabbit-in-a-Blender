
/*********
FIELD_IS_PRIMARY_KEY

Primary Key - verify those fields where IS_PRIMARY_KEY == Yes, the values in that field are unique

Parameters used in this template:
cdmDatabaseSchema = @cdmDatabaseSchema
cdmTableName = @cdmTableName
cdmFieldName = @cdmFieldName
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
		SELECT '@cdmTableName.@cdmFieldName' AS violating_field, cdmTable.* 
		  FROM @cdmDatabaseSchema.@cdmTableName cdmTable
		  {@cohort & '@runForCohort' == 'Yes'}?{
    	JOIN @cohortDatabaseSchema.COHORT c 
    	ON cdmTable.PERSON_ID = c.SUBJECT_ID
    	AND c.COHORT_DEFINITION_ID = @cohortDefinitionId
    	}
		 WHERE cdmTable.@cdmFieldName IN ( SELECT @cdmFieldName 
		                            FROM @cdmDatabaseSchema.@cdmTableName
												 GROUP BY @cdmFieldName
												HAVING COUNT_BIG(*) > 1 ) 
	) violated_rows
) violated_row_count,
( 
	SELECT COUNT_BIG(*) AS num_rows
	FROM @cdmDatabaseSchema.@cdmTableName cdmTable
	{@cohort & '@runForCohort' == 'Yes'}?{
  JOIN @cohortDatabaseSchema.COHORT c 
  ON cdmTable.PERSON_ID = c.SUBJECT_ID
	AND c.COHORT_DEFINITION_ID = @cohortDefinitionId
    	}
) denominator
;