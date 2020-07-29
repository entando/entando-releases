[ -z $ZSH_VERSION ] && [ -z $BASH_VERSION ] && echo "Unsupported shell, user either bash or zsh" 1>&2 && exit 99

T=".wd/cache"
S=".wd/scripts"
D="./dist"

save_cfg_value() {
  local V
  V=$(printf "\"%q\"" "$2")
  if [[ -f $CFG_FILE ]]; then
    sed --in-place='' "/^$1=.*$/d" $CFG_FILE
  fi 
  if [ -n "$2" ]; then
    echo "$1=$V" >> $CFG_FILE
  fi
  return 0
}

reload_cfg() {
  set -a
  # shellcheck disable=SC1091
  [[ -f $CFG_FILE ]] && . $CFG_FILE
  set +a
  return 0
}

REPO_CUSTOM_MODEL_TAG="$CUSTOM_MODEL_VERSION"
REPO_QUICKSTART_TAG="$QUICKSTART_VERSION"
