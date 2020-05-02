SELECT
  match_id,
  unit_id,
  min(step) AS created_at,
  max(step) AS deleted_at
FROM `kaggle-halite.benchmark.units`
GROUP BY match_id, unit_id;
