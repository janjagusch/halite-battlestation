SELECT
  match_id,
  step,
  unit_id,
  CASE
    WHEN action IS NOT NULL THEN action
    WHEN created_at = step THEN NULL
    WHEN shipyard_id IS NOT NULL THEN "DEPOSIT"
    WHEN next_shipyard_action = "CONVERT" THEN next_shipyard_action
    ELSE "MINE"
  END AS action
FROM (
  SELECT 
    ship_actions.match_id,
    ship_actions.player_index,
    ship_actions.step,
    ship_actions.unit_id,
    ship_actions.pos,
    ship_actions.action,
    shipyards.unit_id as shipyard_id,
    next_shipyard_actions.action as next_shipyard_action,
    units_created_deleted_at.created_at 
  FROM (
    SELECT *
    FROM `kaggle-halite.benchmark._units_actions`
    WHERE unit_type = "ship"
  ) AS ship_actions
  LEFT JOIN (
    SELECT *
    FROM `kaggle-halite.benchmark.units` 
    WHERE unit_type = "shipyard"
  ) AS shipyards
  ON ship_actions.match_id = shipyards.match_id
  AND ship_actions.step = shipyards.step
  AND ship_actions.pos = shipyards.pos
  LEFT JOIN (
    SELECT *
    FROM `kaggle-halite.benchmark._units_actions` 
    WHERE unit_type = "shipyard"
  ) as next_shipyard_actions
  ON ship_actions.match_id = next_shipyard_actions.match_id 
  AND ship_actions.step + 1 = next_shipyard_actions.step 
  AND ship_actions.player_index = next_shipyard_actions.player_index 
  AND ship_actions.pos = next_shipyard_actions.pos
  LEFT JOIN `kaggle-halite.benchmark._units_created_deleted_at` as units_created_deleted_at 
  ON ship_actions.match_id = units_created_deleted_at.match_id 
  AND ship_actions.unit_id = units_created_deleted_at.unit_id 
);
