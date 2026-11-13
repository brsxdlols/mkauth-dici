#!/bin/sh
set -eu

REPO="brsxdlols/mkauth-dici"
BRANCH="main"
MK_ROOT="/opt/mk-auth"
ADDON_REL="admin/addons/dici"
MENU_REL="admin/addons/addon.js"
BACKUP_ROOT="$MK_ROOT/backups/dici"
BEGIN_MARKER="// BEGIN mkauth-dici (managed)"
END_MARKER="// END mkauth-dici (managed)"

say() { printf '%s\n' "[mkauth-dici] $*"; }
die() { say "ERRO: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Comando obrigatório ausente: $1"; }

[ "$(id -u)" -eq 0 ] || die "Execute como root."
[ -d "$MK_ROOT/admin/addons" ] || die "MK-Auth não encontrado em $MK_ROOT."
[ -r "$MK_ROOT/include/conexao.php" ] || die "Conexão padrão do MK-Auth não encontrada."
need tar
need php

download() {
    url="$1" dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --silent --show-error --retry 3 --connect-timeout 15 "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q --timeout=30 -O "$dest" "$url"
    else
        die "Instale curl ou wget."
    fi
}

restore_backup() {
    backup="$1"
    [ "$backup" = latest ] && backup="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
    [ -n "$backup" ] && [ -d "$backup" ] || die "Backup não encontrado: $1"
    [ -d "$backup/addon" ] && { rm -rf "$MK_ROOT/$ADDON_REL"; cp -a "$backup/addon" "$MK_ROOT/$ADDON_REL"; }
    [ -f "$backup/addon.js" ] && cp -a "$backup/addon.js" "$MK_ROOT/$MENU_REL"
    say "Rollback concluído: $backup"
    exit 0
}

if [ "${1:-}" = "--rollback" ]; then restore_backup "${2:-latest}"; fi

timestamp="$(date +%Y%m%d-%H%M%S)"
tmp="$(mktemp -d /tmp/mkauth-dici.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
archive="$tmp/source.tar.gz"
download "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" "$archive"
tar -xzf "$archive" -C "$tmp"
src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d -name 'mkauth-dici-*' | head -n 1)"
[ -d "$src/addon" ] && [ -s "$src/VERSION" ] || die "Pacote incompleto."
version="$(tr -d '\r\n' < "$src/VERSION")"
say "Validando versão $version com PHP $(php -r 'echo PHP_VERSION;')..."
find "$src/addon" -type f \( -name '*.php' -o -name '*.hhvm' \) -exec php -l {} \; >/dev/null
grep -q "CONCAT(0xEFBBBF, 'CNPJ')" "$src/addon/ajax_mensal.php" || die "Correção UTF-8 BOM ausente."

backup="$BACKUP_ROOT/$timestamp"
mkdir -p "$backup"
[ ! -e "$MK_ROOT/$ADDON_REL" ] || cp -a "$MK_ROOT/$ADDON_REL" "$backup/addon"
[ ! -e "$MK_ROOT/$MENU_REL" ] || cp -a "$MK_ROOT/$MENU_REL" "$backup/addon.js"
say "Backup criado em $backup"

stage="$tmp/addon.new"
cp -a "$src/addon" "$stage"
find "$stage" -type d -exec chmod 755 {} \;
find "$stage" -type f -exec chmod 644 {} \;
chown -R root:root "$stage"
rm -rf "$MK_ROOT/$ADDON_REL.new"
mv "$stage" "$MK_ROOT/$ADDON_REL.new"
rm -rf "$MK_ROOT/$ADDON_REL"
mv "$MK_ROOT/$ADDON_REL.new" "$MK_ROOT/$ADDON_REL"
mkdir -p "$MK_ROOT/admin/arquivos"

menu="$MK_ROOT/$MENU_REL"
[ -f "$menu" ] || : > "$menu"
awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin { managed=1; next }
    $0 == end { managed=0; next }
    managed { next }
    /addons\/dici\// { next }
    { print }
' "$menu" > "$tmp/addon.js"
{
    cat "$tmp/addon.js"
    printf '\n%s\n' "$BEGIN_MARKER"
    printf '%s\n' "add_menu.provedor('{\"plink\": \"' + minha_url + 'addons/dici/index.php\", \"ptext\": \"DICI / ANATEL\"}');"
    printf '%s\n' "$END_MARKER"
} > "$tmp/addon.js.new"
cp "$tmp/addon.js.new" "$menu"
chmod 644 "$menu"
chown root:root "$menu"

find "$MK_ROOT/$ADDON_REL" -type f \( -name '*.php' -o -name '*.hhvm' \) -exec php -l {} \; >/dev/null
[ "$(grep -cF "$BEGIN_MARKER" "$menu")" -eq 1 ] || die "Registro de menu inválido; use rollback $backup"
printf '%s\n' "$version" > "$MK_ROOT/$ADDON_REL/.installed-version"
say "Instalação $version concluída."
say "Addon: $MK_ROOT/$ADDON_REL"
say "Backup/rollback: sh install.sh --rollback $backup"
