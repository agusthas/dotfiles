#!/usr/bin/env bash

GDRIVE_ID="1bpjwl4NILQ3Lb_76MtOL0sn1BKw_6hcd"
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
doit_tar_gz_dir="doit.tar.gz"

# get doit from gdrive
wget -O "$doit_tar_gz_dir" "https://docs.google.com/uc?export=download&id="$GDRIVE_ID""
tar -xzf $doit_tar_gz_dir

# get cmake
pushd "$cmake_temp_dir"
wget -O "$CMAKE_BASENAME" $CMAKE_DOWNLOAD_URL
tar -xzf "$CMAKE_BASENAME"
CMAKE_BINARY=$(find "$(pwd)" -maxdepth 3 -type f -wholename "*/cmake")

echo "Using CMake binary: $CMAKE_BINARY"
popd

$CMAKE_BINARY .
$CMAKE_BINARY --build .

DOITCLIENT_BINARY=$(find "$(pwd)" -maxdepth 1 -type f -wholename "*/doitclient")

mv "$DOITCLIENT_BINARY" "$HOME" && echo "Binary installed in: $HOME. Move them to the folder listed in \$PATH"
popd

cat <<EOF > "$HOME/.doitrc"
secret $HOME/.doit-secret
EOF