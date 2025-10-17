# Cross Project AI Coding Agent Memory

## General Guidelines

### Communication Style
- **Be concise**: Provide clear, to-the-point responses without unnecessary elaboration
- **Sacrifice grammar for brevity**: Omit articles, use fragments, prioritize speed of communication
- **Ask when uncertain**: Always ask clarifying questions rather than making assumptions about requirements or intent

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

### Live Display
`live-display [JSON_FILE]` - Live visual display for diagrams and images

**Key Features:**
- Watches JSON file for changes and displays visual content in terminal
- Supports images and diagrams (PlantUML, Graphviz DOT, Gnuplot, Ditaa)  
- Uses Kitty terminal's image display capabilities
- Auto-detects git root, defaults to `.live-display.json`
- Auto-watches referenced files for changes

**Files Created:**
- `.live-display.pid` - Process tracking (in git root)
- `.live-display.log` - Debug logging (in git root)

**Usage Note:** Ask user to start `live-display` in a separate terminal instead of running it yourself

#### JSON Format:
```json
{
  "items": [
    {
      "file": "./path/to/image.png",
      "title": "Optional Title"
    },
    {
      "type": "plantuml",
      "content": "@startuml\nA -> B\n@enduml",
      "title": "Inline Diagram"
    }
  ]
}
```

#### Item Requirements:
- Each item must have either `file` OR both `type` and `content` (not both)
- `title` is optional for all items
- File paths resolve relative to git root if not absolute

#### Supported file types:
- **Images**: .png, .jpg, .jpeg, .gif, .bmp, .webp, .svg
- **PlantUML**: .puml, .plantuml
- **Graphviz**: .dot, .gv  
- **Gnuplot**: .gp, .gnuplot, .plt
- **Ditaa**: .ditaa, .dta

#### Supported inline diagram types:
- **plantuml** - Sequence, class, activity, component, use case, state, Gantt, mindmap, etc.
- **dot** - Directed and undirected graphs using DOT language
- **gnuplot** - Mathematical plots and charts (PNG terminal auto-added if missing)
- **ditaa** - ASCII art to diagram conversion
