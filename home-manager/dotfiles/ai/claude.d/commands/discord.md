Read Discord messages by exporting them with DiscordChatExporter CLI.

## Arguments

$ARGUMENTS

## Prerequisites

- `discordchatexporter-cli` must be installed
- `DISCORD_TOKEN` must be set in environment

## Parsing Arguments

Arguments format: `[channel-id-or-url] [--after YYYY-MM-DD] [--before YYYY-MM-DD] [--last Nd|Nw|Nm] [free-text prompt]`

Examples:
- `/discord 123456 --last 3d summarize announcements` → last 3 days, summarize announcements
- `/discord 123456 --after 2026-04-01 --before 2026-04-10 what are the key updates?`
- `/discord 123456` → default last 7 days, show all messages
- `/discord` → list guilds first

Parse rules:
- `--last 3d` = last 3 days, `--last 2w` = last 2 weeks, `--last 1m` = last 1 month
- `--after` / `--before` = exact date range
- If no date flag: default to `--last 7d`
- Everything else after flags = user's custom prompt for how to present/summarize the data

## Workflow

1. If `DISCORD_TOKEN` is not set, tell user to run `export DISCORD_TOKEN="token"`.

2. Parse channel ID:
   - URL `https://discord.com/channels/SERVER_ID/CHANNEL_ID` → extract CHANNEL_ID
   - Number → use as channel ID
   - Empty → list guilds: `discordchatexporter-cli guilds -t "$DISCORD_TOKEN"`, ask user to pick

3. List channels if needed:
   ```bash
   discordchatexporter-cli channels -t "$DISCORD_TOKEN" -g SERVER_ID
   ```

4. Export messages:
   ```bash
   discordchatexporter-cli export -t "$DISCORD_TOKEN" -c CHANNEL_ID -f Json --after DATE --before DATE -o /tmp/discord-export.json
   ```

5. Read `/tmp/discord-export.json` and process:
   - If user provided a custom prompt: follow that prompt to present/summarize the data
   - If no custom prompt: show messages grouped by date with sender, timestamp, and content

## Custom Prompt Examples

- `summarize key announcements` → only show important announcements
- `what are people complaining about?` → focus on complaints/issues
- `list all links shared` → extract URLs only
- `who is most active?` → count messages per user
- `translate to Vietnamese` → translate messages
