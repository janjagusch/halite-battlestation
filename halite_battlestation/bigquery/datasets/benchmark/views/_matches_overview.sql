SELECT
  agents.match_id,
  agents.agent,
  results.halite,
  ranks.rank,
  matches.configuration,
  matches.tags,
  matches.seed,
  matches.inserted_at
FROM `kaggle-halite.benchmark._matches_agent_player_index` AS agents
LEFT JOIN `kaggle-halite.benchmark._matches_result` AS results
ON agents.match_id = results.match_id 
AND agents.player_index = results.player_index
LEFT JOIN `kaggle-halite.benchmark._matches_rank` AS ranks
ON agents.match_id = ranks.match_id 
AND agents.player_index = ranks.player_index
LEFT JOIN `kaggle-halite.benchmark.matches` AS matches
ON agents.match_id = matches.match_id
