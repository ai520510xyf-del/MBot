#!/system/bin/sh
# Node.js wrapper for Android
# Loads libnode.so and forwards all arguments

# Find the native library
LIB_DIR=$(dirname "$0")
APP_LIB="/data/data/com.mbot.mobile/lib"

# Try multiple paths
for dir in "$APP_LIB/arm64" "$APP_LIB/arm" "$LIB_DIR/../lib/arm64" "$LIB_DIR/../lib/arm"; do
    if [ -f "$dir/libnode.so" ]; then
        export LD_LIBRARY_PATH="$dir:$LD_LIBRARY_PATH"
        exec "$dir/libnode" "$@"
    fi
done

echo "Error: libnode.so not found" >&2
exit 1
