[ -z $ZSH_VERSION ] && [ -z $BASH_VERSION ] && echo "Unsupported shell, user either bash or zsh" 1>&2 && exit 99

T="./script/cache"
S="./script/lib"
D="./dist"

clone() {
  local URL="$1"
  local TAG="$2"
  local FLD="$3"
  local DSC="$4"
  local OUT

  if [[ ! -d "$FLD" ]]; then
    (
      set +e
      OUT="$(git clone "$URL" "$FLD" 2>&1)"

      if [ "$?" != 0 ]; then
        echo -e "\n~~~"
        echo -e '/!\\ Unable to clone the repo '"$URL"' /!\\' 2>&1
        echo -e "~~~\n"
        exit 91
      fi
      
      set -e

      if cd "$FLD"; then
        curr_branch="$(git branch --show-current)"
        if [ "$TAG" == "$curr_branch" ]; then
          echo "Please specify a release tag or branch" 1>&2
          git pull
        else
          if ! git checkout "$TAG" &> /dev/null; then
            echo "Retrying to checkout as branch.."
            if ! git checkout -b "$TAG" origin/"$TAG" 1> /dev/null; then
              echo -e "\n~~~"
              echo -e '/!\\ Unable to checkout the provided '"$DSC \"$TAG\""'/!\\\n/!\\' 2>&1
              echo -e "~~~\n"
              exit 92
            fi
          fi
        fi
      fi
      if [ "$?" == 0 ]; then
        cd - 1>/dev/null
      else
        cd - 1>/dev/null
        rm -rf "./$FLD"
        exit "$?"
      fi
    ) || exit "$?"
  else
    echo "Destination dir \"$PWD/$FLD\" already exists and will not be overwritten.." 1>&2
  fi
}

SAMPLE_TMP_DIR="samples"
