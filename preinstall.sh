#!/bin/bash -l
set -euo pipefail

# Directory where all dependencies get downloaded
VENDOR_DIR="$(cd "$(dirname "$0")" && pwd)/vendor"
mkdir -p "$VENDOR_DIR"
cd "$VENDOR_DIR"

# ── helpers ──────────────────────────────────────────────────────────────────

clone_repo() {
    local repo="$1"
    local dir="$(basename "$repo" .git)"
    if [ -d "$dir" ]; then
        echo "SKIP  $dir (already exists)"
    else
        echo "CLONE $repo"
        git clone --depth 1 "$repo"
    fi
}

fetch_tar() {
    local url="$1"
    local archive="$(basename "$url")"
    # figure out the extracted directory name from the first entry
    if [ -n "${2:-}" ]; then
        local dir="$2"
    else
        local dir="${archive%.tar.*}"
        dir="${dir%.tgz}"
    fi

    if [ -d "$dir" ]; then
        echo "SKIP  $dir (already exists)"
        return
    fi

    echo "FETCH $url"
    wget -q "$url" -O "$archive"
    tar xf "$archive"
    rm -f "$archive"
}

fetch_tar_to() {
    local url="$1"
    local dir="$2"
    local archive="$(basename "$url")"

    if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "SKIP  $dir (already exists)"
        return
    fi

    echo "FETCH $url"
    mkdir -p "$dir"
    wget -q "$url" -O "$archive"
    tar xf "$archive" -C "$dir" --strip-components=1
    rm -f "$archive"
}

fetch_zip() {
    local url="$1"
    local dir="$2"

    if [ -d "$dir" ]; then
        echo "SKIP  $dir (already exists)"
        return
    fi

    echo "FETCH $url"
    wget -q "$url" -O tmp_download.zip
    unzip -q tmp_download.zip
    rm -f tmp_download.zip
}

fetch_binary() {
    local url="$1"
    local name="$2"

    if [ -f "$name" ]; then
        echo "SKIP  $name (already exists)"
        return
    fi

    echo "FETCH $url"
    wget -q "$url" -O "$name.tar.gz"
    tar xf "$name.tar.gz"
    rm -f "$name.tar.gz"
}

# ── git repos ────────────────────────────────────────────────────────────────

clone_repo https://github.com/Gaius-Augustus/Augustus
clone_repo https://github.com/Gaius-Augustus/Tiberius
clone_repo https://github.com/LarsGab/EvidencePipeline
clone_repo https://github.com/TransDecoder/TransDecoder
clone_repo https://github.com/tomasbruna/miniprothint
clone_repo https://github.com/lh3/miniprot
clone_repo https://github.com/tomasbruna/miniprot-boundary-scorer

# ── prebuilt binaries / archives ─────────────────────────────────────────────

fetch_tar_to "https://bioinf.uni-greifswald.de/bioinf/tiberius/models/tiberius_weights_v2.tar.gz" \
             "Tiberius/model_weights/tiberius_weights_v2"
           
fetch_zip  "https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download" \
           "hisat2-2.2.1"

fetch_tar  "https://github.com/lh3/minimap2/releases/download/v2.30/minimap2-2.30_x64-linux.tar.bz2" \
           "minimap2-2.30_x64-linux"

fetch_tar  "https://github.com/gpertea/stringtie/releases/download/v3.0.3/stringtie-3.0.3.Linux_x86_64.tar.gz" \
           "stringtie-3.0.3.Linux_x86_64"

fetch_tar  "https://github.com/TransDecoder/TransDecoder/archive/refs/tags/TransDecoder-v5.7.1.tar.gz" \
           "TransDecoder-TransDecoder-v5.7.1"

fetch_tar  "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.3.0/sratoolkit.3.3.0-ubuntu64.tar.gz" \
           "sratoolkit.3.3.0-ubuntu64"

fetch_binary "https://github.com/shenwei356/seqkit/releases/download/v2.11.0/seqkit_linux_amd64.tar.gz" \
             "seqkit"

echo ""
echo "Done. All dependencies in: $VENDOR_DIR"
