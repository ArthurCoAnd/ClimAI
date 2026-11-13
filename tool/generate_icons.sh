#!/usr/bin/env bash
# Gera os ícones do app (Android e Web) a partir de assets/images/icone_clima.svg.
#
# O SVG usa filtros (feTurbulence/feDisplacementMap), por isso a rasterização é
# feita pelo Chrome/Edge em modo headless, que os renderiza fielmente.
#
# Uso: bash tool/generate_icons.sh
#      CHROME=/caminho/do/chrome bash tool/generate_icons.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/images/icone_clima.svg"
# Cor de fundo do SVG, usada nas versões "maskable" (sangria total).
BG="#f3ead7"

if [[ -z "${CHROME:-}" ]]; then
  for c in \
    "/c/Program Files/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "$(command -v google-chrome || true)" \
    "$(command -v chromium || true)"; do
    if [[ -n "$c" && -x "$c" ]]; then CHROME="$c"; break; fi
  done
fi
[[ -n "${CHROME:-}" ]] || { echo "Chrome/Edge não encontrado; defina CHROME." >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp "$SRC" "$TMP/icon.svg"

# Página HTML com o SVG em pixels exatos, ancorado no canto superior esquerdo
# (o Chrome headless pode usar uma viewport mais larga que --window-size em
# tamanhos pequenos, então não dá para usar vw/vh).
page() { # page <plain|maskable> <size>
  local kind="$1" size="$2" bg="transparent" pad=0 inner="$2"
  if [[ "$kind" == maskable ]]; then
    # Maskable: fundo sólido e o desenho dentro da zona segura (80%).
    bg="$BG"; pad=$(( size / 10 )); inner=$(( size - 2 * pad ))
  fi
  cat > "$TMP/page.html" <<HTML
<!doctype html><html><head><style>
html,body{margin:0;background:transparent;overflow:hidden}
.box{position:fixed;left:0;top:0;width:${size}px;height:${size}px;background:$bg}
img{position:absolute;left:${pad}px;top:${pad}px;width:${inner}px;height:${inner}px}
</style></head><body><div class="box"><img src="icon.svg"></div></body></html>
HTML
}

to_url() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1; then p="$(cygpath -m "$p")"; fi
  echo "file:///${p#/}"
}

render() { # render <plain|maskable> <size> <saída>
  local kind="$1" size="$2" out="$3" shot="$TMP/shot.png"
  page "$kind" "$size"
  local shot_arg="$shot"
  if command -v cygpath >/dev/null 2>&1; then shot_arg="$(cygpath -w "$shot")"; fi
  rm -f "$shot"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --no-first-run \
    --allow-file-access-from-files --force-device-scale-factor=1 \
    --default-background-color=00000000 --window-size="$size,$size" \
    --screenshot="$shot_arg" "$(to_url "$TMP/page.html")" >/dev/null 2>&1
  [[ -s "$shot" ]] || { echo "Falha ao renderizar $out" >&2; exit 1; }
  mkdir -p "$(dirname "$out")"
  mv "$shot" "$out"
  echo "  $size×$size  ${out#"$ROOT"/}"
}

echo "Android:"
RES="$ROOT/android/app/src/main/res"
render plain    48  "$RES/mipmap-mdpi/ic_launcher.png"
render plain    72  "$RES/mipmap-hdpi/ic_launcher.png"
render plain    96  "$RES/mipmap-xhdpi/ic_launcher.png"
render plain    144 "$RES/mipmap-xxhdpi/ic_launcher.png"
render plain    192 "$RES/mipmap-xxxhdpi/ic_launcher.png"

echo "Web:"
WEB="$ROOT/web"
render plain    32  "$WEB/favicon.png"
render plain    192 "$WEB/icons/Icon-192.png"
render plain    512 "$WEB/icons/Icon-512.png"
render maskable 192 "$WEB/icons/Icon-maskable-192.png"
render maskable 512 "$WEB/icons/Icon-maskable-512.png"
