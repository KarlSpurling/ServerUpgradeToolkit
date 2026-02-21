FileSnapshot Module
The FileSnapshot module provides deterministic, auditable file inventory snapshots for Windows Server in‑place upgrade workflows. It is designed to capture the full filesystem state before an upgrade and compare it with the post‑upgrade state to validate changes, detect unexpected modifications, and support rollback assurance.

Features
Full file metadata capture (path, size, timestamps, attributes, owner)

Optional SHA256 hashing

CSV output for easy diffing

Drive selection via global JSON config

Wrapper function for simple usage

Snapshot comparison tool

Pester tests included

Fully compatible with PowerShell 5.1

Configuration
A global configuration file controls behaviour across all servers:

ServerUpgradeToolkit/Config/FileSnapshot.json

Example configuration
{
"IncludeDrives": [ "C:" ],
"ExcludeDrives": [ "X:", "Z:" ],
"IncludeHash": false,
"OutputPath": "C:\\Snapshots"
}

Configuration precedence
Command‑line parameters

Config file values

Module defaults

Drive selection behaviour (Whitelist + Blacklist)
If IncludeDrives is present, only those drives are considered.

If ExcludeDrives is present, those drives are removed from the set.

If neither is present, all fixed drives with free space are scanned.

This allows precise control on servers where SAN/iSCSI/USB devices appear as fixed disks.

Usage
Create a snapshot
Invoke-FileSnapshot

With hashing:

Invoke-FileSnapshot -IncludeHash

Snapshot a specific path:

Invoke-FileSnapshot -Path 'D:\Data'

Compare two snapshots
Compare-FileSnapshots -Before snapshot1.csv -After snapshot2.csv

The comparison output includes:

Added files

Removed files

Modified files (size, timestamp, hash)

Output
Snapshots are written to the configured output directory (default: .\Snapshots) with filenames like:

FileSnapshot-20260221-074501.csv

Purpose
This module is designed to support the ServerUpgradeToolkit by providing:

Pre‑upgrade filesystem state capture

Post‑upgrade validation

Rollback assurance

Change auditing

Deterministic, repeatable upgrade workflows

It fits into the toolkit’s philosophy of safe, predictable, and well‑documented Windows Server upgrades.

Tests
Pester tests are included under:

Modules/FileSnapshot/Tests/

They validate:

Snapshot generation

Wrapper/config behaviour

Snapshot diffing

These tests can be integrated into CI pipelines to ensure long‑term reliability.

Version
1.0.0 — Initial release with snapshotting, diffing, config support, and Pester tests.
