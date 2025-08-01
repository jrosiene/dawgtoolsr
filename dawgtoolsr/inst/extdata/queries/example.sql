-- Example query for testing dawgtoolsr
-- This query demonstrates parameter substitution

SELECT 
    1 as col1,
    %(test_value)s as col2,
    '{date}' as col3
FROM (SELECT 1 as dummy) t
WHERE 1 = 1