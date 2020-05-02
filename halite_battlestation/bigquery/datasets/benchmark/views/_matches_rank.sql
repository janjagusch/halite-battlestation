SELECT
  match_id,
  player_index,
  COUNTIF(loss) + 1 as rank
FROM (
  SELECT 
    results_1.match_id,
    results_1.player_index,
    CASE
      WHEN results_2.reward IS NULL THEN FALSE
      WHEN results_1.reward IS NULL THEN TRUE
      WHEN results_2.reward > results_1.reward THEN TRUE
      ELSE FALSE
    END AS loss
  FROM `kaggle-halite.benchmark._matches_result` AS results_1
  INNER JOIN `kaggle-halite.benchmark._matches_result` as results_2
  ON results_1.match_id = results_2.match_id
  AND results_1.player_index != results_2.player_index
)
GROUP BY match_id, player_index
