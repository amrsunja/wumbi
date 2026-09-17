#!/usr/bin/env bash
# Post-deploy check for wumbi.app. Run it from a normal terminal after every
# deploy — a sandboxed shell will not reach the live host.
#   ./wumbi_landing/smoke.sh
set -uo pipefail
HOST="${HOST:-https://wumbi.app}"
fail=0

head1() { curl -sI --max-time 15 "$HOST$1" | head -1 | tr -d '\r'; }
code()  { head1 "$1" | grep -oE '[0-9]{3}' | head -1; }
loc()   { curl -sI --max-time 15 "$HOST$1" | grep -i '^location:' | tr -d '\r' | sed 's/^[Ll]ocation: *//'; }

expect() { # path  expected-code
  local got; got=$(code "$1")
  if [ "$got" != "$2" ]; then printf 'FAIL %-46s %s (want %s)\n' "$1" "${got:-–}" "$2"; fail=1
  else printf 'ok   %-46s %s\n' "$1" "$got"; fi
}

expect_loc() { # path  expected-location
  local got; got=$(loc "$1")
  if [ "$got" != "$2" ]; then printf 'FAIL %-46s -> %s (want %s)\n' "$1" "${got:-–}" "$2"; fail=1
  else printf 'ok   %-46s -> %s\n' "$1" "$got"; fi
}

echo "--- what is actually live ---"
# Check the status BEFORE reading the body, or a 404 page gets mistaken for a stamp.
live=""
if [ "$(code /build-stamp.txt)" = "200" ]; then
  live=$(curl -s --max-time 15 "$HOST/build-stamp.txt" | head -1 | tr -d '\r')
  case "$live" in [0-9][0-9][0-9][0-9]-*Z\ *) ;; *) live="" ;; esac
fi
local_stamp=$(head -1 "$(dirname "$0")/dist/build-stamp.txt" 2>/dev/null | tr -d '\r')
printf '     live on server : %s\n' "${live:-<no build-stamp.txt — deploy predates it>}"
printf '     built locally  : %s\n' "${local_stamp:-<no local build>}"
if [ -z "$live" ]; then
  echo "     !! cannot confirm which build is live; the checks below still stand on their own"
elif [ "$live" != "$local_stamp" ]; then
  echo "     !! the server is NOT serving this build — redeploy before trusting anything below"
  fail=1
fi
echo

echo "--- the duplicate must be gone ---"
expect     /wumbi_landing/dist/                              301
expect     /wumbi_landing/dist/ru/                           301
expect     /wumbi_landing/dist/free-budget-planner-template/ 301
expect_loc /wumbi_landing/dist/                              "$HOST/"
expect_loc /wumbi_landing/dist/ru/                           "$HOST/ru/"

echo "--- repository sources must be gone ---"
# 403 counts as gone too: Hostinger blocks some paths (/.git/*) at server level,
# before .htaccess ever runs. 410 is preferred — Google drops it fastest — but any
# of 403/404/410 keeps the URL out of the index.
for u in /wumbi_landing/ /wumbi_landing/build.mjs /wumbi_landing/seo.config.mjs \
         /wumbi_app/pubspec.yaml /docs/ /package.json /.git/config ; do
  got=$(code "$u")
  case "$got" in 403|404|410) printf 'ok   %-46s %s\n' "$u" "$got" ;;
    *) printf 'FAIL %-46s %s (want 403/404/410)\n' "$u" "${got:-–}"; fail=1 ;;
  esac
done

echo "--- canonical host: one hop, never to the internal path ---"
expect_loc_host() {
  local got; got=$(curl -sI --max-time 15 "$1" | grep -i '^location:' | tr -d '\r' | sed 's/^[Ll]ocation: *//')
  if [ "$got" != "$2" ]; then printf 'FAIL %-46s -> %s (want %s)\n' "$1" "${got:-–}" "$2"; fail=1
  else printf 'ok   %-46s -> %s\n' "$1" "$got"; fi
}
expect_loc_host https://www.wumbi.app/ru/ "https://wumbi.app/ru/"
expect_loc_host http://wumbi.app/ru/      "https://wumbi.app/ru/"

echo "--- the site must still be up ---"
for p in / /fr/ /de/ /nl/ /tr/ /ru/ /ar/ /free-budget-planner-template/ \
         /about/ /privacy/ /terms/ /press/ /sitemap.xml /robots.txt \
         /assets/templates/Wumbi-Budget-Planner-Template.xlsx ; do
  expect "$p" 200
done

echo
[ "$fail" = 0 ] && echo "PASS" || echo "FAILURES above"
exit $fail
