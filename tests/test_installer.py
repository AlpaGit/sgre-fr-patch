import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PS = Path(os.environ["SystemRoot"]) / "System32/WindowsPowerShell/v1.0/powershell.exe"


def sha(data):
    return hashlib.sha256(data).hexdigest().upper()


class InstallerTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix="sgre-fr-test-")
        self.addCleanup(tmp.cleanup)
        root = Path(tmp.name)
        self.bundle = root / "download"
        shutil.copytree(ROOT / "installer", self.bundle / "installer")
        apps = root / "SteamLibrary" / "steamapps"
        self.game = apps / "common" / "SGRE"
        self.data = self.game / "wind3d11data"
        self.data.mkdir(parents=True)
        (self.game / "sgre_steam.exe").touch()
        self.backup = self.game / ".sgre-fr-backup-25953359"
        self.manifest = apps / "appmanifest_4012810.acf"
        self.write_manifest("25953359")
        build = json.loads((ROOT / "installer/build.json").read_text(encoding="utf-8"))
        self.targets = [item["path"] for item in build["files"]]
        self.interface = [item["path"] for item in build["interface"]]
        for item in build["files"] + build["interface"]:
            name = item["path"]
            original, french = self.bytes_for("steam", name), self.bytes_for("fr", name)
            self.store(self.data / name, original)
            item["steam"] = sha(original)
            if "fr" in item:
                self.store(self.bundle / "patch" / name, french)
                item["fr"] = sha(french)
        self.store(self.bundle / "installer/build.json", json.dumps(build).encode())

    def write_manifest(self, build):
        self.manifest.write_text(
            f'"AppState"\n{{\n "appid" "4012810"\n "installdir" "SGRE"\n'
            f' "buildid" "{build}"\n "StateFlags" "4"\n}}\n',
            encoding="ascii",
        )

    @staticmethod
    def bytes_for(kind, name):
        return f"{kind} {name}".encode()

    @staticmethod
    def store(path, data):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)

    def run_patch(self, mode="install", success=True):
        proc = subprocess.run(
            [str(PS), "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass",
             "-File", str(self.bundle / "installer" / f"{mode}.ps1"), "-GameDir", str(self.game)],
            capture_output=True, text=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW,
        )
        log = proc.stdout + proc.stderr
        self.assertEqual(proc.returncode, 0 if success else 1, log)
        return log

    def check_files(self, folder, kind):
        for name in self.targets:
            self.assertEqual((folder / name).read_bytes(), self.bytes_for(kind, name), name)

    def test_roundtrip_ignores_legacy_backups_and_handles_repeat_runs(self):
        legacy = self.data / (self.targets[0] + ".bak")
        legacy.write_bytes(b"old build")
        for _ in range(2):
            self.run_patch()
            self.check_files(self.data, "fr")
        self.check_files(self.backup, "steam")
        for _ in range(2):
            self.run_patch("uninstall")
            self.check_files(self.data, "steam")
        self.assertEqual(legacy.read_bytes(), b"old build")
        for name in self.interface:
            self.assertEqual((self.data / name).read_bytes(), self.bytes_for("steam", name))

    def test_refuses_wrong_steam_build_on_install_and_uninstall(self):
        self.run_patch()
        self.write_manifest("9999")
        for mode in ("install", "uninstall"):
            self.assertIn("Steam incompatible", self.run_patch(mode, success=False))
            self.check_files(self.data, "fr")

    def test_refuses_modified_interface_and_mismatched_payload(self):
        filename = self.interface[0]
        (self.data / filename).write_bytes(b"old interface mod")
        self.assertIn("interface non officielle", self.run_patch(success=False))
        self.check_files(self.data, "steam")
        (self.data / filename).write_bytes(self.bytes_for("steam", filename))
        (self.bundle / "patch" / self.targets[-1]).write_bytes(b"broken download")
        self.assertIn("Patch incomplet", self.run_patch(success=False))
        self.check_files(self.data, "steam")

    def test_uninstall_refuses_corrupt_backup_without_partial_restore(self):
        self.run_patch()
        (self.backup / self.targets[-1]).write_bytes(b"old build")
        self.assertIn("Sauvegarde absente ou invalide", self.run_patch("uninstall", success=False))
        self.check_files(self.data, "fr")

    def test_failed_swap_rolls_back_files_already_replaced(self):
        # Windows readers allow hashing but deny replacing a file open without delete sharing.
        with (self.data / self.targets[-1]).open("rb"):
            self.assertIn("Replace", self.run_patch(success=False))
        self.check_files(self.backup, "steam")
        self.check_files(self.data, "steam")
        self.run_patch()
        self.check_files(self.data, "fr")


if __name__ == "__main__":
    unittest.main()
