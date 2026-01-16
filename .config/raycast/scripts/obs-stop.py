# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "obsws-python",
# ]
# ///

import logging
import os
import subprocess
import sys
import time
from pathlib import Path

from obsws_python import ReqClient

_DEBUG = False
_format = ""
if _DEBUG:
    _format = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.INFO, format=_format)
_logger = logging.getLogger(__name__)


def _get_input_args() -> str:
    meeting_name = sys.argv[1]
    if not meeting_name:
        raise ValueError("Meeting name is required")

    return meeting_name


def _stop_recording(host: str, port: int, password: str) -> None:
    client = ReqClient(host=host, port=port, password=password)
    status = client.get_record_status()
    if not status.output_active:
        _logger.info("録画中ではありません。")
        return

    # OBS上のステータスが停止になるまで待機
    client.stop_record()
    for _ in range(20):
        time.sleep(0.5)
        if not client.get_record_status().output_active:
            return

    raise RuntimeError("Failed to stop recording in OBS.")


def _search_latest_file(directory: Path, pattern: str) -> Path:
    list_of_files = [f for f in directory.glob(pattern) if f.is_file()]

    if len(list_of_files) == 0:
        raise RuntimeError("録画ファイルなし")

    latest_file = max(list_of_files, key=os.path.getctime)

    return latest_file


def _wait_for_file_unlock(file_path: Path) -> None:
    # lsofコマンドでOSレベルのファイルロックを確認（安全装置）
    for _ in range(60):
        if os.system(f"lsof '{file_path.absolute()}' > /dev/null 2>&1") != 0:
            return
        time.sleep(1)

    raise RuntimeError("File is still locked after waiting.")


def _get_destination_path(src: Path, dst_dir: Path, meeting_name: str) -> Path:
    created_ts = src.stat().st_ctime
    t = time.localtime(created_ts)

    date_str = time.strftime("%Y%m%d", t)
    month_str = f"{t.tm_mon:02d}"
    dest_dir = dst_dir / month_str / f"{date_str}-{meeting_name}"

    ext = src.suffix
    filepath = dest_dir / f"{meeting_name}{ext}"

    return filepath


def _quit_obs() -> None:
    try:
        subprocess.run(
            ["osascript", "-e", 'quit app "OBS"'],
            check=False,
            capture_output=True,
            timeout=5,
        )
    except Exception:
        _logger.warning("Failed to quit OBS via AppleScript, ignoring")


def main() -> None:
    REC_DIR = Path("~/Movies").expanduser()
    TARGET_DIR = Path("~/meeting_records").expanduser()

    OBS_HOST = "localhost"
    OBS_PORT = 24455
    OBS_PASSWORD = "BW4RxC6oFlIqVSLw"

    meeting_name = _get_input_args()

    _stop_recording(host=OBS_HOST, port=OBS_PORT, password=OBS_PASSWORD)

    latest_file = _search_latest_file(REC_DIR, "*.mov")
    _wait_for_file_unlock(latest_file)

    dest_file = _get_destination_path(
        src=latest_file, dst_dir=TARGET_DIR, meeting_name=meeting_name
    )
    dest_file.parent.mkdir(parents=True, exist_ok=True)
    latest_file.rename(dest_file)
    _logger.info(f"保存完了: {dest_file}")

    _quit_obs()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        _logger.exception("Error occurred")
