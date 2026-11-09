#!/usr/bin/env bash
#
# gnome-keyring Settings Script

# Guard if command does not exist.
if ! type gnome-keyring-daemon >/dev/null 2>&1; then return 0; fi

# The keyring locks again after a reboot. The password is piped straight from pass to the
# unlock script so it never lands in a shell variable or on the command line.
function unlock_keyring_from_pass() {
  if ! type pass >/dev/null 2>&1; then
    echo "pass command not found. Please install pass to use this function." >&2
    return 1
  fi

  # An empty stdin makes the script abort, so a failing pass still returns non-zero.
  pass show keyring/login |
    /usr/bin/python3 -I "$_DOTFILES_CONFIG_DIR/gnome-keyring/unlock-login-keyring.py"
}
