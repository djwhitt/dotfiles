set -l npm_packages "$HOME/.npm-packages"
if test -d $npm_packages
  set -gx NPM_PACKAGES $npm_packages
  contains "$npm_packages/bin" $fish_user_paths; or set -Ua fish_user_paths "$npm_packages/bin"
end
