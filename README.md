
```
~/Applications/
├── Makefile
├── *.AppImage                          (your existing AppImages)
└── appimage-updater/
    ├── lib/
    │   └── common.sh                   (shared functions: version compare, download, backup, etc.)
    └── apps/
        ├── aider.sh                    ← paul-gauthier/aider
        ├── arduino.sh                  ← arduino/arduino-ide
        ├── dbgate.sh                   ← dbgate/dbgate
        ├── logseq.sh                   ← logseq/logseq
        ├── mattermost.sh               ← mattermost/desktop
        ├── mqtt-explorer.sh            ← thomasnordquist/MQTT-Explorer
        ├── obsidian.sh                 ← obsidianmd/obsidian-releases
        ├── redis-insight.sh            ← RedisInsight/RedisInsight (ASAR extraction)
        ├── smplayer.sh                 ← smplayer-dev/smplayer
        ├── teams-for-linux.sh          ← IsmaelMartinez/teams-for-linux
        ├── veracrypt.sh                ← veracrypt/VeraCrypt
        └── zcode.sh                    ← zcode.z.ai (web scraper)
```


# AppImage Updater

Checks installed AppImages for updates and offers to download new versions.

## Requirements

- `curl` and `jq`
- GitHub token for authenticated API requests (avoids rate limits)

## Usage

```bash
# Check and update all applications
make

# Update a single application
make aider-desk
make -C ~/Applications obsidian
make -C ~/Applications redis-insight

# Check multiple specific apps
make -C ~/Applications logseq dbgate veracrypt
```

Set `GITHUB_TOKEN` to avoid rate limits:

```bash
export GITHUB_TOKEN=$(gh auth token)
make -C ~/Applications
```

The Makefile auto-detects the token from `gh auth token` if available.

## Available targets

| Target | Application |
|--------|------------|
| `aider-desk` | Aider Desk |
| `arduino` | Arduino IDE |
| `dbgate` | DbGate |
| `logseq` | Logseq |
| `mattermost` | Mattermost Desktop |
| `mqtt-explorer` | MQTT Explorer |
| `obsidian` | Obsidian |
| `redis-insight` | Redis Insight |
| `smplayer` | SMPlayer |
| `teams-for-linux` | Teams for Linux |
| `veracrypt` | VeraCrypt |
| `zcode` | ZCode |
| `all` | All of the above |
