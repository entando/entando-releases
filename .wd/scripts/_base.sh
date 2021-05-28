[ -z $ZSH_VERSION ] && [ -z $BASH_VERSION ] && echo "Unsupported shell, user either bash or zsh" 1>&2 && exit 99

T="./.wd/cache"
S="./.wd/scripts"
D="./dist"

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
        cd - 1>/dev/null
      else
        cd - 1>/dev/null
        rm -rf "./$FLD"
        exit "$?"
      fi
    )
  else
    echo "Destination dir \"$PWD/$FLD\" already exists and will not be overwritten.." 1>&2
  fi
}

CURRENT_HELM_VERSION=$(helm version --client --short)
if [[ "$CURRENT_HELM_VERSION" =~ ^2\..* ]] || [[ "$CURRENT_HELM_VERSION" =~ ^v2\..* ]]; then
  HELM_VERSION_MAJOR=2
elif [[ "$CURRENT_HELM_VERSION" =~ ^3\..* ]] || [[ "$CURRENT_HELM_VERSION" =~ ^v3\..* ]]; then
  HELM_VERSION_MAJOR=3
else
  echo "> FATAL: Found helm version $CURRENT_HELM_VERSION but only versions 2 and 3 are supported" 1>&2
  exit 1
fi
