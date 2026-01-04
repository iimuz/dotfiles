# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "obsws-python",
# ]
# ///

"""Start or connect to OBS and begin recording a configured scene."""

import logging
import subprocess
import time

from obsws_python import ReqClient

_DEBUG = False

# logging setup
_log_level = logging.INFO if not _DEBUG else logging.DEBUG
_log_format = "" if not _DEBUG else "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=_log_level, format=_log_format)
_logger = logging.getLogger(__name__)


class OBSStartError(Exception):
    """Raised when OBS cannot be started or connected to."""

    pass


def _connect_obs(
    host: str, port: int, password: str, retries: int = 5, delay: int = 2
) -> ReqClient:
    """Connect to OBS WebSocket, launching OBS if necessary and retrying.

    Args:
        host: Hostname for the OBS WebSocket (typically "localhost").
        port: Port for the OBS WebSocket.
        password: Password for the OBS WebSocket.
        retries: Number of times to retry after starting OBS.
        delay: Seconds to wait between retries.

    Returns:
        A connected ReqClient instance.

    Raises:
        OBSStartError: If unable to connect after the configured retries.
    """
    # 初回の接続は失敗しても続行
    try:
        client = ReqClient(host=host, port=port, password=password)
        return client
    except Exception:
        pass

    # 接続に失敗したので OBS を起動
    try:
        subprocess.run(["open", "-a", "OBS"], check=True)
        time.sleep(3)  # OBS起動待ち
    except Exception:
        _logger.exception("Failed to start OBS")
        return None

    # 接続の再試行
    for i in range(retries):
        try:
            client = ReqClient(host=host, port=port, password=password)
            return client
        except Exception as e:
            if i < retries:
                time.sleep(delay)
                continue

            raise OBSStartError("Failed to connect to OBS") from e


def main() -> None:
    """Main entry point to ensure OBS records the target scene."""
    OBS_HOST = "localhost"
    OBS_PORT = 24455
    OBS_PASSWORD = "BW4RxC6oFlIqVSLw"

    TARGET_SCENE = "MacScreenCapture"

    # OBS への接続確立
    client = _connect_obs(
        host=OBS_HOST, port=OBS_PORT, password=OBS_PASSWORD, retries=5, delay=2
    )
    status = client.get_record_status()
    if status.output_active:
        _logger.info("Recording already in progress")
        return

    # 撮影するシーンに切り替え
    client.set_current_program_scene(name=TARGET_SCENE)
    time.sleep(0.5)

    # 撮影開始
    client.start_record()
    _logger.info("Started recording")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        _logger.exception("Error occurred")
