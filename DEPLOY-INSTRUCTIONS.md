Steps to deploy to GitHub Pages:

1. On github.com, create a new PUBLIC repository named **kodie-ypg** (Settings -> General -> Repository name).

2. Upload all files in this zip to the repository root:
   - Open the repo -> Add file -> Upload files
   - Drag-and-drop every file and folder in this zip (index.html, assets/, manifest.json, icons/, logo.png, sw.js, etc.)
   - Commit changes.

3. Enable GitHub Pages:
   - Go to Settings -> Pages
   - Branch: main, Folder: / (root)
   - Click Save

4. Wait 1-2 minutes, then visit:
   https://<your-github-username>.github.io/kodie-ypg/

Notes:
- Do NOT upload the src/ folder to the repo. Only the contents of this zip.
- If you clear browser storage, log in again with: admin / 1234
- To update later: rebuild locally, replace all repo files with the new dist/ contents, commit.

