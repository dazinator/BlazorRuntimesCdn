#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$REPO_ROOT/runtimes-config.json"
RUNTIMES_DIR="$REPO_ROOT/runtimes"
TEMP_DIR="$(mktemp -d)"

echo "=== Blazor Runtime Provisioning Script ==="
echo "Repository: $REPO_ROOT"
echo "Config: $CONFIG_FILE"
echo "Runtimes directory: $RUNTIMES_DIR"
echo

# Track if any changes were made
CHANGES_MADE=false

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        echo "Cleaning up temporary directory..."
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Parse config and provision runtimes
echo "Reading configuration from $CONFIG_FILE"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Create runtimes directory if it doesn't exist
mkdir -p "$RUNTIMES_DIR"

# Get list of enabled runtime versions
ENABLED_VERSIONS=$(jq -r '.runtimes[] | select(.enabled == true) | .version' "$CONFIG_FILE")

if [ -z "$ENABLED_VERSIONS" ]; then
    echo "No enabled runtimes found in configuration."
else
    echo "Enabled runtimes: $(echo "$ENABLED_VERSIONS" | tr '\n' ', ' | sed 's/,$//')"
    echo
fi

# Process each enabled runtime
for VERSION in $ENABLED_VERSIONS; do
    echo "--- Processing runtime version: $VERSION ---"
    
    RUNTIME_DIR="$RUNTIMES_DIR/$VERSION"
    
    # Check if runtime already exists
    if [ -d "$RUNTIME_DIR" ] && [ "$(ls -A "$RUNTIME_DIR" 2>/dev/null)" ]; then
        echo "✓ Runtime $VERSION already exists, skipping provisioning."
        continue
    fi
    
    echo "Provisioning runtime $VERSION..."
    
    # Get dotnet version from config
    DOTNET_VERSION=$(jq -r ".runtimes[] | select(.version == \"$VERSION\") | .dotnetVersion" "$CONFIG_FILE")
    
    # Determine the framework moniker (e.g., net8.0, net9.0)
    FRAMEWORK_VERSION=$(echo "$DOTNET_VERSION" | cut -d. -f1,2)
    FRAMEWORK_MONIKER="net${FRAMEWORK_VERSION}"
    
    echo "Using .NET SDK version: $DOTNET_VERSION"
    echo "Framework moniker: $FRAMEWORK_MONIKER"
    
    # Create temporary project
    TEMP_PROJECT_DIR="$TEMP_DIR/blazor-temp-$VERSION"
    echo "Creating temporary Blazor WASM project in $TEMP_PROJECT_DIR..."
    
    dotnet new blazorwasm -n TempBlazorApp -o "$TEMP_PROJECT_DIR" --framework "$FRAMEWORK_MONIKER" --no-restore
    
    # Restore and publish the project
    echo "Publishing project to extract runtime files..."
    dotnet publish "$TEMP_PROJECT_DIR" -c Release -o "$TEMP_PROJECT_DIR/publish" --nologo -v quiet
    
    # Create runtime directory
    mkdir -p "$RUNTIME_DIR"
    
    # Copy runtime files from the published output
    FRAMEWORK_DIR="$TEMP_PROJECT_DIR/publish/wwwroot/_framework"
    
    if [ ! -d "$FRAMEWORK_DIR" ]; then
        echo "ERROR: Framework directory not found: $FRAMEWORK_DIR"
        exit 1
    fi
    
    echo "Extracting runtime files..."
    
    # Copy all dotnet.* files (runtime files)
    find "$FRAMEWORK_DIR" -maxdepth 1 \( \
        -name "dotnet.*.js" -o \
        -name "dotnet.*.wasm" -o \
        -name "dotnet.native.*.wasm" -o \
        -name "dotnet.native.worker.*.js" -o \
        -name "dotnet.runtime.*.js" -o \
        -name "dotnet.js.map" \
    \) -exec cp {} "$RUNTIME_DIR/" \;
    
    # Also copy icudt files if they exist (internationalization data)
    find "$FRAMEWORK_DIR" -maxdepth 1 -name "icudt*.dat" -exec cp {} "$RUNTIME_DIR/" \; 2>/dev/null || true
    
    FILE_COUNT=$(ls -1 "$RUNTIME_DIR" | wc -l)
    echo "✓ Extracted $FILE_COUNT runtime files to $RUNTIME_DIR"
    ls -lh "$RUNTIME_DIR"
    
    CHANGES_MADE=true
    
    # Cleanup temp project
    echo "Cleaning up temporary project..."
    rm -rf "$TEMP_PROJECT_DIR"
    echo
done

# Remove runtime directories that are not in the config or are disabled
echo "--- Cleaning up unused runtime directories ---"
if [ -d "$RUNTIMES_DIR" ]; then
    for RUNTIME_DIR in "$RUNTIMES_DIR"/*/ ; do
        if [ -d "$RUNTIME_DIR" ]; then
            DIRNAME=$(basename "$RUNTIME_DIR")
            
            # Check if this version is in the config and enabled
            IS_ENABLED=$(jq -r ".runtimes[] | select(.version == \"$DIRNAME\" and .enabled == true) | .version" "$CONFIG_FILE")
            
            if [ -z "$IS_ENABLED" ]; then
                echo "Removing unused runtime directory: $DIRNAME"
                rm -rf "$RUNTIME_DIR"
                CHANGES_MADE=true
            fi
        fi
    done
fi

echo
echo "=== Provisioning Complete ==="
if [ "$CHANGES_MADE" = true ]; then
    echo "Status: Changes were made to runtime files"
    exit 1  # Exit with 1 to indicate changes
else
    echo "Status: No changes needed"
    exit 0  # Exit with 0 to indicate no changes
fi
