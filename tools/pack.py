"""Build and validate the Windows end-user ZIP from the release tree."""

import argparse
import hashlib
import json
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SUPPORT_FILES = (
    "install.bat", "uninstall.bat", "installer/install.ps1", "installer/uninstall.ps1",
    "installer/patch.ps1", "installer/build.json", "README.md", "LICENSE", "CHANGELOG.md",
    "SHA256SUMS.txt", "docs/installation.md", "docs/faq.md", "docs/credits.md", "patch/README.md",
)


def digest(stream):
    return hashlib.file_digest(stream, "sha256").hexdigest().upper()


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--movies", type=Path, required=True, help="Directory of the three FR videos")
    cli.add_argument("zip", type=Path, help="Output archive (must not already exist)")
    args = cli.parse_args()

    build = json.loads((ROOT / "installer/build.json").read_text(encoding="utf-8"))
    expected = {f"patch/{file['path']}": file["fr"] for file in build["files"]}
    checksums = dict(reversed(line.split(maxsplit=1)) for line in
                     (ROOT / "SHA256SUMS.txt").read_text(encoding="utf-8").splitlines())
    if checksums != expected:
        raise ValueError("SHA256SUMS.txt and installer/build.json disagree")

    sources = {name: ROOT / name for name in SUPPORT_FILES}
    for name, sha in expected.items():
        path = args.movies / Path(name).name if name.startswith("patch/movie/") else ROOT / name
        with path.open("rb") as stream:
            if digest(stream) != sha:
                raise ValueError(f"Invalid input SHA-256: {path}")
        sources[name] = path
    for path in sources.values():
        if not path.is_file():
            raise FileNotFoundError(path)

    with args.zip.open("xb") as output:
        with zipfile.ZipFile(output, "w") as archive:
            for name, path in sources.items():
                # Use fixed metadata so identical inputs produce identical ZIPs.
                info = zipfile.ZipInfo(f"{args.zip.stem}/{name}", (2026, 11, 18, 0, 0, 0))
                info.compress_type = zipfile.ZIP_STORED
                with path.open("rb") as source, archive.open(info, "w") as member:
                    shutil.copyfileobj(source, member)
    with zipfile.ZipFile(args.zip) as archive:
        for name, sha in expected.items():
            with archive.open(f"{args.zip.stem}/{name}") as stream:
                if digest(stream) != sha:
                    raise ValueError(f"Invalid packaged SHA-256: {name}")
        bad = archive.testzip()
        if bad:
            raise ValueError(f"Invalid ZIP member CRC: {bad}")
    with args.zip.open("rb") as stream:
        print(f"{digest(stream)}  {args.zip.name}")


if __name__ == "__main__":
    main()
