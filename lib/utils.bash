#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for thefuck.
GH_REPO="https://github.com/nvbn/thefuck"
TOOL_NAME="thefuck"
TOOL_TEST="thefuck --help"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if thefuck is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if thefuck has other means of determining installable versions.
  list_github_tags
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  # TODO: Adapt the release URL convention for thefuck
  # url="$GH_REPO/archive/v${version}.tar.gz"
  url="$GH_REPO/archive/refs/tags/${version}.tar.gz"

  echo "* Downloading $TOOL_NAME release $version..."
  # https://github.com/nvbn/thefuck/archive/refs/tags/3.32.tar.gz
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  local venv_args=()
  local pip_args=("--disable-pip-version-check")

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    # mkdir -p /tmp/asdf-test
    # echo "[DEBUG] 1 $ASDF_DOWNLOAD_PATH // $install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
    # cp -r "$ASDF_DOWNLOAD_PATH"/* /tmp/asdf-test

    if ! asdf plugin list | grep python; then
      fail "Cannot install $TOOL_NAME $version - asdf python plugin is not installed!"
    fi

    if ! asdf which python3; then
      fail "Cannot install $TOOL_NAME $version - python3 is not installed!"
    fi

    ASDF_RESOLVED_PYTHON_PATH=$(asdf which python3)

    # special check for macOS
    if [ "$ASDF_RESOLVED_PYTHON_PATH" == "/usr/bin/python3" ] && [[ "$OSTYPE" == "darwin"* ]]; then
      log "Copying /usr/bin/python3 on macOS does not work, symlinking"
    else
      venv_args+=("--copies")
    fi

    cd $install_path

    # Make a venv for the app
    local venv_path="$install_path"/venv
    "$ASDF_RESOLVED_PYTHON_PATH" -m venv ${venv_args[@]+"${venv_args[@]}"} "$venv_path"
    "$venv_path"/bin/python3 -m pip install ${pip_args[@]+"${pip_args[@]}"} --upgrade setuptools
    "$venv_path"/bin/python3 -m pip install ${pip_args[@]+"${pip_args[@]}"} --upgrade pip wheel

    "$venv_path"/bin/python3 -m pip install -Ur requirements.txt
    "$venv_path"/bin/python3 setup.py build
    "$venv_path"/bin/python3 setup.py install

    # TODO: Assert thefuck executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    # rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
