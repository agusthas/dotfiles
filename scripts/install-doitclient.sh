#!/usr/bin/env bash

APP_BIN_DIR="$HOME/bin"
while getopts ":d:" opt; do
  case $opt in
    d)
      APP_BIN_DIR="$OPTARG"
      ;;
  esac
done
shift $((OPTIND-1))

if [[ ! -d "$APP_BIN_DIR" ]]; then
  mkdir -p "$APP_BIN_DIR"
fi

GDRIVE_ID="1p0jXJbJM_cp83fxUhF05aGLJbmbCSTTY"
DOIT_BASENAME="doit.zip"
CMAKE_DOWNLOAD_URL="https://github.com/Kitware/CMake/releases/download/v3.23.3/cmake-3.23.3-linux-x86_64.tar.gz" # pick linux-x86_64 tar.gz version
CMAKE_BASENAME=$(basename $CMAKE_DOWNLOAD_URL) # get the filename

cmake_temp_dir=$(mktemp -d)
doit_temp_dir=$(mktemp -d)
cleanup() {
  rm -rf $cmake_temp_dir $doit_temp_dir
}
trap cleanup SIGHUP SIGINT SIGTERM EXIT

pushd "$doit_temp_dir"
doit_zip_dir="doit.zip"

# get doit from gdrive
http -b \
  --timeout 5 \
  --download https://docs.google.com/uc export==download id=="$GDRIVE_ID" >> $doit_zip_dir
# extract doit to $doit_temp_dir
unzip $doit_zip_dir

# get cmake
pushd "$cmake_temp_dir"
http -b \
  --timeout 5 \
  --download https://github.com/Kitware/CMake/releases/download/v3.23.3/cmake-3.23.3-linux-x86_64.tar.gz >> "$CMAKE_BASENAME"
tar -xzf "$CMAKE_BASENAME"
CMAKE_BINARY=$(find "$(pwd)" -type f -wholename "*/cmake")

echo "Using CMake binary: $CMAKE_BINARY"
popd

$CMAKE_BINARY .
$CMAKE_BINARY --build .

DOITCLIENT_BINARY=$(find "$(pwd)" -type f -wholename "*/doitclient")

mv "$DOITCLIENT_BINARY" "$APP_BIN_DIR"
popd