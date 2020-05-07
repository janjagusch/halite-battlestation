SELECT
  match_id,
  agent,
  REGEXP_REPLACE(agent, ".*:", "") AS agent_short,
  row_number() OVER (PARTITION BY match_id) - 1 AS player_index
FROM (
  SELECT * EXCEPT(agents)
  FROM `kaggle-halite.benchmark._matches_latest`,
  UNNEST(agents) as agent
);
