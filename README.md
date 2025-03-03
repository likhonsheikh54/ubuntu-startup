# Ubuntu Startup and Security Hardening Script

![Bash](https://img.shields.io/badge/Language-Bash-blue) ![License](https://img.shields.io/badge/License-MIT-green) [![GitHub Issues](https://img.shields.io/github/issues/likhonsheikh54/ubuntu-startup)](https://github.com/likhonsheikh54/ubuntu-startup/issues) [![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen)](https://github.com/likhonsheikh54/ubuntu-startup/pulls)

This Bash script automates initial security hardening and setup for Ubuntu servers. It streamlines essential configurations to secure your VPS or cloud instance.

## Features

- **System Updates**: Full package update/upgrade
- **Firewall (UFW)**: Configure basic rules for SSH and traffic control
- **Fail2Ban**: Brute-force protection for SSH
- **Malware Scans**: ClamAV (antivirus) and rkhunter (rootkit detection)
- **SSH Security**: Disable root login, optional passwordless authentication
- **User Management**: Create non-root sudo user with SSH key support
- **Automatic Updates**: Enable unattended security upgrades

## Requirements

- Ubuntu 18.04+ (tested on 22.04 LTS)
- Root/sudo access
- Internet connection

## Usage

1. **Download Script**
   ```bash
   wget https://raw.githubusercontent.com/likhonsheikh54/ubuntu-startup/main/ubuntu-startup.sh
   ```

2. **Make Executable**
   ```bash
   chmod +x ubuntu-startup.sh
   ```

3. **Run as Root**
   ```bash
   sudo ./ubuntu-startup.sh
   ```

## Post-Installation

1. **Test New User Access**
   ```bash
   ssh newuser@your_server_ip
   ```

2. **Verify SSH Key Login** (if configured)
   ```bash
   ssh -i ~/.ssh/your_private_key newuser@your_server_ip
   ```

3. **Check Firewall Status**
   ```bash
   ufw status verbose
   ```

4. **Monitor Fail2Ban**
   ```bash
   fail2ban-client status sshd
   ```

## Customization

- **SSH Port**: Modify `ufw allow OpenSSH` and `/etc/ssh/sshd_config` if using custom port
- **Fail2Ban Rules**: Adjust `maxretry` and `bantime` in `/etc/fail2ban/jail.local`
- **Scan Schedules**: Add cron jobs for regular ClamAV/rkhunter scans

## Contribution

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a Pull Request

Report issues [here](https://github.com/likhonsheikh54/ubuntu-startup/issues).

## License

MIT License - see [LICENSE](LICENSE) file

---

**Note**: Always test in a non-production environment before deployment. Backup critical data before running system-altering scripts.
