SELECT * except(row_number)
FROM (
  SELECT
    *,
    row_number() OVER (PARTITION BY match_id, step, player_index ORDER BY inserted_at DESC) AS row_number
  FROM `kaggle-halite.benchmark.players`
)
WHERE row_number=1;
