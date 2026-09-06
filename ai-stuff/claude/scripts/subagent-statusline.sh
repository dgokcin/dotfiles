#!/bin/bash
# Custom row content for Claude Code's subagent panel.
# Reads all visible tasks from stdin and emits one JSON line per task.

input=$(cat)

printf '%s' "$input" | jq -c '
  (.columns // 120) as $columns
  | .tasks[]?
  | (.name // .label // .id) as $name
  | (.model // "resolving model…") as $model
  | ([$name, "model: \($model)", (.description // "")]
      | map(select(length > 0))
      | join(" · ")) as $content
  | ([($columns - 1), 1] | max) as $limit
  | {
      id,
      content: (if ($content | length) > $columns
        then $content[0:$limit] + "…"
        else $content
      end)
    }
'
