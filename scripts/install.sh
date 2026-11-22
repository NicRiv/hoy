#!/usr/bin/env bash

#
#   @NicRiv
#

set -euo pipefail

REPO="NicRiv/hoy"
BIN="hoy"

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo amd64 ;;
        aarch64|arm64)  echo arm64 ;;
        *) echo "Arquitectura no soportada: $(uname -m)" >&2; exit 1 ;;
    esac
}

fetch_latest_version() {
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | grep -oP '"tag_name":\s*"\K[^"]+' | head -n1
}

main() {
    local arch version url tmp target
    arch="$(detect_arch)"
    version="${hoy_VERSION:-$(fetch_latest_version)}"

    if [ -z "$version" ]; then
        echo "No se pudo determinar la última versión." >&2
        exit 1
    fi

    url="https://github.com/${REPO}/releases/download/${version}/${BIN}-linux-${arch}"
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT

    echo "Descargando ${BIN} ${version} (${arch})..."
    curl -fsSL "$url" -o "$tmp"
    chmod +x "$tmp"

    if [ "$(id -u)" -eq 0 ]; then
        target="/usr/local/bin/${BIN}"
        install -m 755 "$tmp" "$target"
    elif command -v sudo >/dev/null 2>&1; then
        target="/usr/local/bin/${BIN}"
        sudo install -m 755 "$tmp" "$target"
    else
        target="${HOME}/.local/bin/${BIN}"
        mkdir -p "$(dirname "$target")"
        install -m 755 "$tmp" "$target"
        case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) echo "⚠️  Agregá $HOME/.local/bin al PATH" >&2 ;;
        esac
    fi

    echo "✅ Instalado en ${target}"
    echo "   Probá con:  ${BIN}"
}

main "$@"