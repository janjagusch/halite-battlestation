SELECT
    units.*,
    actions.action
FROM `kaggle-halite.benchmark.units` AS units
LEFT JOIN `kaggle-halite.benchmark.actions` AS actions
ON units.match_id = actions.match_id
AND units.step = actions.step
AND units.unit_id = actions.unit_id;
