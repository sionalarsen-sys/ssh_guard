# 🛡️ SSH Guard: Brute-Force Mitigation Tool

A Bash-based security utility designed for **Blue Team** automation. This tool monitors system authentication logs, identifies high-frequency failure patterns, and prepares dynamic firewall responses to mitigate brute-force attacks.

## 🚀 Overview
This project was developed as a final portfolio piece for **IT 135 (Introduction to Linux)** at **North Seattle College**. It demonstrates proficiency in Bash scripting, log analysis, and security automation.

### 🔑 Key Features
* **Automated Log Analysis:** Uses `grep` and `awk` to parse `sshd` logs for malicious patterns.
* **Smart Throttling:** Blocks IPs only after crossing a user-defined failure threshold.
* **Safety First:** Includes a Whitelist feature to prevent administrative lockout.
* **Audit Logging:** Maintains a forensic trail of all identified threats and actions taken.
* **Interactive Setup:** Includes a first-time configuration wizard for easy deployment.

## 🔍 Case Study: The Problem & The Solution
### Background
In a standard production environment, a server exposed to the internet can face thousands of unauthorized SSH connection attempts per hour. Manual monitoring of /var/log/auth.log is impossible for a human operator, and leaving these attempts unmitigated risks a successful brute-force compromise.

### The Problem
The administration team needed an automated "Blue Team" utility to:

1. Identify high-frequency failure patterns across massive log files.

2. Filter out legitimate administrative traffic (Whitelisting).

3. Audit and Execute defensive actions (Firewall blocking) without manual intervention.

### The Solution
The `ssh_guard.sh` script implements a modular security pipeline. It extracts "Failed" and "Invalid" login attempts into a persisten failure log for analysis, uses `awk` to aggregate hit counts by IP address, and compares those counts against a user-defined threshold. By separating the Analysis Engine from the Setup Configuration, the script can be deployed across various Linux environments with zero code modification.

## 🛠️ Technical Stack
* **Language:** Bash (Shell Scripting)
* **Tools:** `awk`, `grep`, `sed`, `nftables` (planned integration)
* **Environment:** Developed and tested in GitHub Codespaces (Ubuntu Linux)

## 📂 Project Structure
* `/src`: Contains the core `ssh_guard.sh` logic and `log_gen.sh`, a custom testing utility to simulate SSH attacks.
* `/resources`: Directory for log processing (contains `.gitkeep`).
* `ssh_guard.conf`: Local configuration (user-defined).

## 🚦 Getting Started
1. **Clone the repo:** `git clone <your-repo-link>`
2. **Set Permissions:** `chmod +x src/*.sh`
3. **Run the Generator:** `bash src/log_gen.sh` (Creates 20 simulated failed logins).
4. **Run SSH Guard:** `bash src/ssh_guard.sh`

## ⚙️ Usage

### Prerequisites

A Linux environment (Bash shell) with standard utilities (`grep`, `awk`, `sort`, `uniq` `tee`).

### 1\. Script Execution

First, ensure your scripts are executable, then run the guard:

```bash
chmod +x src/*.sh
./src/ssh_guard.sh
```

### 2\. The Core Command Pipeline (For reference)
The script utilizes a piped sequence to transform raw log data into actionable security intelligence:

```bash
# 1. Isolate IP addresses from failure logs
# 2. Sort and count unique occurrences
# 3. Pass data to the decision-making loop

awk '{print $11}' "$FAIL" | sort | uniq -c | while read COUNT IP; do
    if [[ "$COUNT" -ge "$THRESHOLD" ]]; then
        # Check against Whitelist and Audit Log before acting
        grep -q "$IP" "$WHITELIST" || log_msg "ACTION: Blocking $IP"
    fi
done
```

The use of `uniq -c` provides an immediate tally of attempts per IP, allowing for precise threshold enforcement.

### 3\. Reviewing Audit Logs
The resulting `audit_log.txt` provides a forensic timeline of actions taken, ensuring the security team has a clear record of blocked threats:

```text
[2026-03-25 14:10:01] ACTION: Blocking 172.16.0.45 (12 failures detected)
[2026-03-25 14:10:05] NOTICE: 192.168.1.20 is whitelisted. Skipping.
[2026-03-25 14:12:30] ACTION: Blocking 10.10.5.122 (8 failures detected)
```
## 🗺️ Roadmap & Future Enhancements

While the core analysis engine is functional, the following features are planned for future releases to improve system hygiene and performance:

* **Log Rotation & Cleanup:** Implementing a "Cleanup" routine to compress or archive `master_fail_log.txt` after processing to prevent disk space exhaustion.
* **Active Firewall Integration:** Transitioning from "Logging-only" mode to active mitigation using `nftables` or `iptables` API calls.
* **Discord/Slack Webhooks:** Adding real-time notifications to alert administrators when a high-priority block occurs.
* **Config Validation:** Adding a pre-flight check to ensure the user-provided paths in `ssh_guard.conf` have the correct read/write permissions.

## 🤝 Attribution and Professional Disclosure

### Base Repository/Code Reference

This project was based on initial concepts and structures derived from the "Linux Text Processing Tools" module at North Seattle College (IT135). 

### AI/Chatbot Assistance Policy

In line with academic integrity and modern development practices, I utilized Google's Gemini large language model (LLM) for the following purposes:

1.  **Syntax Debugging:** Correcting missed punctuation and variables.
2.  **Code Review:** Verifying best practices for shell variable usage and quoting.
3.  **Documentation Drafting:** Structuring and refining the language used in this `README.md` and the initial project overview.

No copyrighted code was used, and the final script logic was engineered and tested independently.

-----

## 👤 Author

* **Siona Larsen**
* **[linkedin link]
* **Educational Context:** Created for IT 135, North Seattle College.
