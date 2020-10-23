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

clone() {
  local URL="$1"
  local TAG="$2"
  local FLD="$3"
  local DSC="$4"

  if [[ ! -d "$FLD" ]]; then
    (
      git clone "$URL" "$FLD"
      if cd "$FLD"; then
        curr_branch="$(git branch --show-current)"
        if [ "$TAG" == "$curr_branch" ]; then
          echo "Please specify a release tag or branch" 1>&2
          git pull
        else
          git fetch --tags
          if ! git checkout -b "$TAG" "$TAG" 1> /dev/null; then
            echo "Retrying to checkout as branch.."
            if ! git checkout -b "$TAG" origin/"$TAG" 1> /dev/null; then
              echo -e '/!\\\n/!\\ Unable to checkout the provided '"$DSC \"$TAG\""'/!\\\n/!\\' 2>&1
              exit 92
            fi
          fi
        fi
      fi
      if [ $? ]; then
        cd -
      else
        cd -
        rm -rf "./$FLD"
        exit "$?"
      fi
    )
  else
    echo "Destination dir \"$PWD/$FLD\" already exists and will not be overwritten.." 1>&2
  fi
}

REPO_CUSTOM_MODEL_TAG="$CUSTOM_MODEL_VERSION"
REPO_QUICKSTART_TAG="$QUICKSTART_VERSION"
