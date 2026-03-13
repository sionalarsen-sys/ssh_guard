# script-template
A repo on which to build scripting projects

Linux Mastery: Scripting & Automation Template

North Seattle College | IT135 Intro to Linux
Overview

This repository is a professional-grade development environment for Linux Bash scripting. It is designed to transition students from basic command execution to building modular, documented, and industrial-strength tools.

This environment is specifically tuned for the LAMP, Docker, and Docker Compose lab sequences, providing a robust library (/lib) and a standardized execution path (/bin).
Getting Started with GitHub Codespaces

    Click the "Code" button in this repository.

    Select the "Codespaces" tab and click "Create codespace on main."

    Once the environment loads, wait for the terminal to appear.

    The system will automatically run install-tools.sh and setup-env.sh to configure your workspace.

    To finalize the setup in your current terminal, run:
    . ./bin/repo.sh

Core Tools

This repo includes specialized tools to verify your environment and demonstrate advanced scripting techniques:
1. The Environment Doctor (check-env.sh)

If your commands aren't working or your paths feel "broken," run the diagnostic tool:
Command: check-env.sh
Purpose: Verifies REPO_ROOT, PATH settings, global symlinks, and software dependencies like 'bc'.
2. The Starfleet Navigator (example.sh)

A demonstration of "Pro-level" scripting.
Command: ./bin/example.sh
Features:

    Floating point math using 'bc'.

    Precise arrival date calculation using Unix Epoch seconds (avoiding the "same day/month" calendar trap).

    Professional flag parsing (-h for help, -d for debug mode).

    Input validation via the shared /lib/tools.sh library.

Features & Standards

    Modular Library: /lib/tools.sh provides validated input functions (getInteger, getNumber) and debugging suites.

    Debug Architecture: Integrated -d flags and DEBUG=1 environmental overrides for real-time code tracing.

    Standardized Documentation: All scripts follow the Google Shell Style Guide for headers and function commentary.

    Portability: The environment tethering in ~/.bashrc uses guard clauses, allowing this folder to be moved to local WSL or Linux machines without breaking the system shell.

License & Ethics
License

This project is licensed under the Apache License 2.0. This allows for free use and modification in educational and professional contexts while maintaining authorship and providing no warranty.
AI Collaboration Statement

This repository template was developed through a collaborative partnership between Professor Bill Newman and Gemini (Google AI).

    Role of Human: Architectural design, pedagogical strategy, logic verification, and educational context.

    Role of AI: Syntax optimization, documentation standardization, and regex refinement.

    Purpose: To demonstrate the industry standard of "AI-Augmented Engineering," where AI acts as a high-velocity pair-programmer to ensure code quality and adherence to global standards.

Authorship

    Lead Instructor: Bill Newman

    Contributors: Gemini (AI Assistant)

    Version: 1.2.1

    Updated: March 12, 2026
