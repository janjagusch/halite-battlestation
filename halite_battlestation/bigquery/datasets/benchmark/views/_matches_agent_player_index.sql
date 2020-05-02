SELECT
  match_id,
  agent,
  row_number() OVER (PARTITION BY match_id) - 1 AS player_index
FROM (
  SELECT * EXCEPT(agents)
  FROM `kaggle-halite.benchmark.matches`,
  UNNEST(agents) as agent
);
