# fpLive

fpLive is a simple file-watching utility for Free Pascal. It automatically rebuilds and runs your program whenever changes are detected in your source files.

Think of it as a lightweight "live reloader" for Free Pascal development.

## Installation

Install using [Nova](https://github.com/nova-packager/nova).

```bash
nova require daar/fplive --dev
```

## ✨ Features
- Watches `.pp`, `.pas` and `.inc` source files in your project directory.
- Detects file changes and recompiles automatically with **fpc**.
- Runs the compiled program immediately after a successful build.
- Supports additional `-Fu` and `-FU` compiler options for unit search paths.

## 🚀 Usage

```bash
./vendor/bin/live ./example/main.pp -Fu./src
```

1. Start the watcher with your main source file.
2. Edit and save your pascal files.
3. fpLive will detect changes, rebuild with `fpc`, and run the program automatically.

Press `Ctrl+C` to stop the watcher.