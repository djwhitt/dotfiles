function __bb_complete_tasks
  bb tasks |tail -n +3 |cut -f1 -d ' ' 
end

complete -c bb -a "(__bb_complete_tasks)" -d 'tasks'
