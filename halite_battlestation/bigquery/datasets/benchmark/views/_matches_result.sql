SELECT
    match_id,
    player_index,
    step,
    halite,
    reward
FROM (
    SELECT
        *,
        row_number() OVER (PARTITION BY match_id, player_index ORDER BY step DESC) AS row_number
    FROM `kaggle-halite.benchmark.players`
)
WHERE row_number = 1
ORDER BY match_id, player_index;
