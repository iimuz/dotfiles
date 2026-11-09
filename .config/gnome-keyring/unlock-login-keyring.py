#!/usr/bin/python3 -I
"""Create or unlock the gnome-keyring login collection with a password read from stdin."""

import sys

import dbus

BUS_NAME = "org.freedesktop.secrets"
SERVICE_PATH = "/org/freedesktop/secrets"
LOGIN_PATH = "/org/freedesktop/secrets/collection/login"


def main() -> int:
    password = sys.stdin.buffer.read().rstrip(b"\n")
    if not password:
        print("empty password on stdin; aborting", file=sys.stderr)
        return 1

    bus = dbus.SessionBus()
    service_obj = bus.get_object(BUS_NAME, SERVICE_PATH)
    service = dbus.Interface(service_obj, "org.freedesktop.Secret.Service")
    internal = dbus.Interface(
        service_obj, "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface"
    )

    # The session must live on this connection; gnome-keyring rejects secrets
    # that reference a session opened by another caller.
    _, session = service.OpenSession("plain", dbus.String("", variant_level=1))
    secret = dbus.Struct(
        (session, dbus.ByteArray(b""), dbus.ByteArray(password), "text/plain"),
        signature="oayays",
    )

    collections = [
        str(p)
        for p in service_obj.Get(
            "org.freedesktop.Secret.Service",
            "Collections",
            dbus_interface="org.freedesktop.DBus.Properties",
        )
    ]
    if LOGIN_PATH in collections:
        internal.UnlockWithMasterPassword(dbus.ObjectPath(LOGIN_PATH), secret)
        print("login keyring unlocked")
    else:
        # gnome-keyring derives the object path from the label verbatim, and
        # clients such as go-keyring look up collection/login.
        props = {"org.freedesktop.Secret.Collection.Label": dbus.String("login")}
        path = internal.CreateWithMasterPassword(dbus.Dictionary(props, signature="sv"), secret)
        print(f"login keyring created: {path}")
        if str(path) != LOGIN_PATH:
            print(f"unexpected collection path: {path}", file=sys.stderr)
            return 1

    service.SetAlias("default", dbus.ObjectPath(LOGIN_PATH))
    return 0


if __name__ == "__main__":
    sys.exit(main())
