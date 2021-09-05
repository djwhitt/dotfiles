function bw-login
  mkdir -p ~/.cache/bw/
  bw login --raw >> ~/.cache/bw/cli-session-id
end

function bw-lock
  set -e BW_SESSION
end

function bw-unlock
  set -gx BW_SESSION (cat ~/.cache/bw/cli-session-id)
end

# wbu (with bitwarden unlocked)
function wbu
  set -x BW_SESSION (cat ~/.cache/bw/cli-session-id)
  bw $argv
end
