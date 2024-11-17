function __d_complete_tasks
  d tasks |tail -n +3 |awk '{printf "%s\t%s\n", $1, substr($0, index($0,$2))}'
end

complete -f -c d -a "(__d_complete_tasks)"
