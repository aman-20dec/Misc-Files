WITH Survey_Points (course_name, points)
AS
  (
      SELECT 
        c.course,
        SUM(c.points)
      FROM
        survey s 
          CROSS APPLY 
                (VALUES 
                    (s.option_a, CASE
                                    WHEN ABS(CAST(s.votes_a AS float) - s.votes_b) / (s.votes_a + s.votes_b) > 0.05 
                                      THEN CASE
                                              WHEN (s.votes_a - s.votes_b) > 0 
                                                 THEN 1
                                                 ELSE 0
                                              END
                                      ELSE 0.5
                                    END
                    ),
                    (s.option_b, CASE
                                    WHEN ABS(CAST(s.votes_a AS float) - s.votes_b) / (s.votes_a + s.votes_b) > 0.05 
                                      THEN CASE
                                              WHEN (s.votes_a - s.votes_b) > 0 
                                                 THEN 0
                                                 ELSE 1
                                              END
                                      ELSE 0.5
                                    END
                    )
                ) as c(course, points)
         GROUP BY c.course
    )
    
  SELECT 
    c.course_name,
    ISNULL(s.points, 0) AS points
  FROM
    course c LEFT JOIN Survey_Points s
      ON c.course_name = s.course_name
  ORDER BY
    ISNULL(s.points, 0) desc , c.course_name