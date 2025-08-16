# Cross Project AI Coding Agent Memory

## Tools Available

### Clipboard Access
- `copyq` - Access current clipboard content and clipboard history
  - Use `&clipboard` tab for main clipboard
  - Use `agents` tab for communicating with other AI agents (OpenCode, Claude Code, etc.)
  - Ignore other tabs (transcripts, prompts, responses)

#### Common copyq commands:
- `copyq clipboard` - Get current clipboard content
- `copyq select [ROW]` - Copy item from history to clipboard (0 = most recent)
- `copyq read [ROW]` - Read item without copying to clipboard
- `copyq count` - Number of items in current tab
- `copyq add TEXT` - Add text to current tab
- `copyq tab` - List all tabs
- `copyq tab NAME read ROW` - Read from specific tab
- `copyq tab NAME add TEXT` - Add to specific tab
- `copyq tab NAME count` - Count items in specific tab
