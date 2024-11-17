function __bb_complete_tasks
  bb tasks |tail -n +3 |awk '{printf "%s\t%s\n", $1, substr($0, index($0,$2))}'
end

complete -c bb -a "(__bb_complete_tasks)" -d 'tasks'
