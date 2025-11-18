# Cross Project AI Coding Agent Memory

## Tools Available

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
