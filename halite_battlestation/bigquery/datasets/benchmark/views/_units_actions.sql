SELECT
    units.*,
    actions.action
FROM `kaggle-halite.benchmark._units_latest` AS units
LEFT JOIN `kaggle-halite.benchmark._actions_latest` AS actions
ON units.match_id = actions.match_id
AND units.step = actions.step
AND units.unit_id = actions.unit_id;
