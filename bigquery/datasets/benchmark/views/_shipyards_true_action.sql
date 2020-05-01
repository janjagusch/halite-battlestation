SELECT
  match_id,
  player_index
  step,
  unit_id,
  CASE
    WHEN action = "SPAWN" THEN action
    ELSE NULL
  END AS action  
FROM `kaggle-halite.benchmark._units_actions` 
WHERE unit_type = "shipyard";
