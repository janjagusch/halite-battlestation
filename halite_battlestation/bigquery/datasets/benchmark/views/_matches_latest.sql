SELECT * except(row_number)
FROM (
  SELECT
    *,
    row_number() OVER (PARTITION BY match_id ORDER BY inserted_at DESC) AS row_number
  FROM `kaggle-halite.benchmark.matches`
)
WHERE row_number=1;