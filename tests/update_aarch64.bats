#!/usr/bin/env bats

setup() {
  UPDATE="$BATS_TEST_DIRNAME/../update_aarch64.sh"
  TEST_HOME="$BATS_TEST_TMPDIR/home"
  STUB_BIN="$BATS_TEST_TMPDIR/bin"
  SYS_BIN="$BATS_TEST_TMPDIR/sys"
  STUB_LOG="$BATS_TEST_TMPDIR/stub.log"
  SNAP_LIST="$BATS_TEST_TMPDIR/snap-list"
  mkdir -p "$TEST_HOME" "$STUB_BIN" "$SYS_BIN"
  : >"$STUB_LOG"

  cat >"$STUB_BIN/stub" <<'STUB'
#!/bin/bash
name=$(basename "$0")
echo "$name $*" >>"$STUB_LOG"
case "$name $*" in "${STUB_FAIL:-<none>}"*) exit 1 ;; esac
exit 0
STUB
  chmod +x "$STUB_BIN/stub"
  # mktemp も stub にする (macOS の mktemp は --suffix を受け付けない)
  for c in sudo gh mise mktemp orca-ide claude playwright-cli; do
    ln -s stub "$STUB_BIN/$c"
  done

  cat >"$STUB_BIN/snap" <<'STUB'
#!/bin/bash
echo "snap $*" >>"$STUB_LOG"
if [ "$*" = "list --all" ]; then
  cat "$SNAP_LIST"
fi
exit 0
STUB
  chmod +x "$STUB_BIN/snap"

  for c in awk rm cat basename; do
    ln -s "$(command -v "$c")" "$SYS_BIN/$c"
  done

  cat >"$SNAP_LIST" <<'LIST'
Name             Version   Rev    Tracking       Publisher    Notes
core20           20240111  2182   latest/stable  canonical✓   base,disabled
core20           20240416  2318   latest/stable  canonical✓   base
lxd              5.21.1    28460  5.21/stable    canonical✓   disabled
lxd              5.21.2    29351  5.21/stable    canonical✓   -
disabled-helper  1.0       12     latest/stable  someone      -
snapd            2.63      21759  latest/stable  canonical✓   snapd
LIST
}

run_update() {
  run env -i HOME="$TEST_HOME" PATH="$STUB_BIN:$SYS_BIN" \
    STUB_LOG="$STUB_LOG" SNAP_LIST="$SNAP_LIST" "$@" /bin/bash "$UPDATE"
}

line_of() {
  grep -n "^$1" "$STUB_LOG" | head -n 1 | cut -d: -f1
}

@test "update_aarch64.sh: vacuums the journal after apt" {
  run_update
  [ "$status" -eq 0 ]
  grep -qx "sudo journalctl --vacuum-size=500M" "$STUB_LOG"
  [ "$(line_of 'sudo apt autoremove -y$')" -lt "$(line_of 'sudo journalctl --vacuum-size=500M$')" ]
}

@test "update_aarch64.sh: selects disabled snaps by the Notes column only" {
  run_update
  [ "$status" -eq 0 ]
  [ "$(grep -c "^sudo snap remove" "$STUB_LOG")" -eq 2 ]
  grep -qx "sudo snap remove core20 --revision=2182" "$STUB_LOG"
  grep -qx "sudo snap remove lxd --revision=28460" "$STUB_LOG"
  ! grep "snap remove" "$STUB_LOG" | grep -qE "disabled-helper|2318|29351" || false
  grep -qx "snap list --all" "$STUB_LOG"
}

@test "update_aarch64.sh: no disabled snaps removes nothing" {
  cat >"$SNAP_LIST" <<'LIST'
Name   Version  Rev   Tracking       Publisher   Notes
lxd    5.21.2   29351 5.21/stable    canonical✓  -
LIST
  run_update
  [ "$status" -eq 0 ]
  grep -qx "snap list --all" "$STUB_LOG"
  ! grep -q "snap remove" "$STUB_LOG" || false
}

@test "update_aarch64.sh: missing snap is skipped" {
  rm "$STUB_BIN/snap"
  run_update
  [ "$status" -eq 0 ]
  ! grep -q "snap" "$STUB_LOG" || false
  grep -qx "sudo journalctl --vacuum-size=500M" "$STUB_LOG"
}

@test "update_aarch64.sh: snap removal failure stops the script" {
  run_update STUB_FAIL="sudo snap remove"
  [ "$status" -ne 0 ]
  grep -qx "sudo snap remove core20 --revision=2182" "$STUB_LOG"
}

@test "update_aarch64.sh: root cleanup runs after the tool updates" {
  run_update STUB_FAIL="sudo snap remove"
  [ "$status" -ne 0 ]
  grep -qx "gh extension upgrade --all" "$STUB_LOG"
  grep -qx "mise install" "$STUB_LOG"
  grep -qx "playwright-cli install-browser chromium --with-deps" "$STUB_LOG"
  [ "$(line_of 'playwright-cli install-browser')" -lt "$(line_of 'sudo journalctl --vacuum-size=500M$')" ]
  [ "$(line_of 'sudo journalctl --vacuum-size=500M$')" -lt "$(line_of 'snap list --all$')" ]
}
