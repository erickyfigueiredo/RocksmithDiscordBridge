# Privacy and release contents

The application does not implement telemetry, analytics, log uploads or a network service. It reads the local game process and its audio shared memory, then plays that audio on the Windows device selected by the user. Steam and Discord are separate applications with their own behavior and policies.

Local settings and diagnostics can contain an audio-device name, process IDs, counters and file paths. Backups contain the installation's original DLL/configuration and its local game path. These files stay on the machine. They are excluded from source control and from the release ZIP.

The repository contains source code, synthetic test fixtures, upstream MIT-licensed fixtures, build/test automation, documentation and license notices. It does not contain game files, music, local user configuration, machine inventories, credentials, logs or backups. References to the repository owner in documentation links identify this public GitHub project, not a Windows account.

The release packager uses an explicit allowlist for installer/docs and includes only the player executable, its runtime, the built DLL and license files. Windows binaries published by GitHub Actions are built on the hosted runner, not copied from a developer's game directory. The source code remains available independently of those binary downloads.

Before posting a bug report, review any logs you attach and remove personal paths and device identifiers you do not want public. The app does not submit reports automatically.
