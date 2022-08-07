#!/usr/bin/env bash

GDRIVE_ID="1bpjwl4NILQ3Lb_76MtOL0sn1BKw_6hcd"
CMAKE_DOWNLOAD_URL="https://github.com/Kitware/CMake/releases/download/v3.23.3/cmake-3.23.3-linux-x86_64.tar.gz" # pick linux-x86_64 tar.gz version
CMAKE_BASENAME=$(basename $CMAKE_DOWNLOAD_URL) # get the filename

cmake_temp_dir=$(mktemp -d)
doit_temp_dir=$(mktemp -d)
cleanup() {
  rm -rf $cmake_temp_dir $doit_temp_dir
}
trap cleanup SIGHUP SIGINT SIGTERM EXIT

pushd "$doit_temp_dir" || exit 1
doit_tar_gz_dir="doit.tar.gz"

# get doit from gdrive
wget -O "$doit_tar_gz_dir" "https://docs.google.com/uc?export=download&id="$GDRIVE_ID"" || exit 1
tar -xzf $doit_tar_gz_dir || exit 1

# get cmake
pushd "$cmake_temp_dir" || exit 1
wget -O "$CMAKE_BASENAME" $CMAKE_DOWNLOAD_URL || exit 1
tar -xzf "$CMAKE_BASENAME" || exit 1
CMAKE_BINARY=$(find "$(pwd)" -maxdepth 3 -type f -wholename "*/cmake")

echo "Using CMake binary: $CMAKE_BINARY"
popd

$CMAKE_BINARY .
$CMAKE_BINARY --build .

DOITCLIENT_BINARY=$(find "$(pwd)" -maxdepth 1 -type f -wholename "*/doitclient")
popd || exit 1

curr_dir="$(pwd)"
echo "======================="
echo "By default this script install to $curr_dir"

mv "$DOITCLIENT_BINARY" "$curr_dir" && echo "Binary installed in: $curr_dir. Move them to the folder listed in \$PATH"

echo "Creating doitrc in $curr_dir/.doitrc"
cat <<EOF > "$curr_dir/.doitrc"
secret $HOME/.doit-secret
EOF

echo "Generating secrets"
dd if=/dev/random of=$curr_dir/.doit-secret bs=64 count=1

echo "==============="
echo "INSTRUCTIONS"
echo "Move doitclient to any folder listed in \$PATH"
echo "Move both .doitrc and .doit-secret to $HOME"
echo "DONE"
