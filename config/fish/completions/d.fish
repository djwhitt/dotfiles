function __d_complete_tasks
  d tasks |tail -n +3 |cut -f1 -d ' ' 
end

complete -f -c d -a "(__d_complete_tasks)" -d 'tasks'
