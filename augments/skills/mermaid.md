# Mermaid Diagrams

Render flowcharts, sequence diagrams, state machines, Gantt charts, and more from Mermaid.js syntax.

## Setup

1. **Install mermaid-cli globally:**
   ```bash
   npm install -g @mermaid-js/mermaid-cli
   ```

2. **Install Chromium** (required by Puppeteer for rendering):
   ```bash
   apt install -y chromium-browser
   # or
   npx puppeteer browsers install chrome
   ```

3. **Create a Puppeteer config** for headless rendering (required when running as root):
   ```json
   {
     "args": ["--no-sandbox", "--disable-setuid-sandbox"]
   }
   ```
   Save as `skills/mermaid/references/puppeteer-config.json`.

4. **Create the skill folder:**
   ```
   skills/mermaid/
   ├── SKILL.md
   ├── references/
   │   └── puppeteer-config.json
   └── scripts/
       └── render_mermaid.sh
   ```

## Usage

```bash
# Write diagram to .mmd file, then render
mmdc -i diagram.mmd -o output.png -b transparent \
  -p skills/mermaid/references/puppeteer-config.json
```

Or use the helper script:
```bash
bash skills/mermaid/scripts/render_mermaid.sh input.mmd output.png
```

## Supported Diagram Types

- `flowchart` — process flows, decision trees
- `sequenceDiagram` — API calls, interactions
- `stateDiagram-v2` — state machines
- `gantt` — project timelines
- `erDiagram` — entity relationships
- `classDiagram` — class structures

## Tips

- Use `LR` layout for wide diagrams, `TD` for tall ones
- Keep to 5-15 nodes per diagram
- Store `.mmd` source alongside `.png` output for future editing
