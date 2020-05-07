SELECT * except(row_number)
FROM (
  SELECT
    *,
    row_number() OVER (PARTITION BY match_id, step, unit_id ORDER BY inserted_at DESC) AS row_number
  FROM `kaggle-halite.benchmark.units`
)
WHERE row_number=1;
