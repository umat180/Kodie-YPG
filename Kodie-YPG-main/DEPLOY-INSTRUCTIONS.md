LATEST FIX (Bulk Voice Calls / recorded messages):
- The recording converter was creating a WAV file about 3x too long (for example a 10-second message became ~29 seconds, mostly silence/DC). That made voice campaigns get charged but fail to play correctly.
- The converter now writes the correct number of samples, so the uploaded file matches the length of the recording.
- Files changed: index.html, sw.js, assets/index-D93X-Xn5-fixed.js (new), and the other assets/index-*.js copies.
- Re-upload index.html, sw.js and the assets/ folder. Then hard-refresh twice (Ctrl+Shift+R) or clear the site data so the old service worker cache is replaced.

Steps to deploy to GitHub Pages:

1. On github.com, open your repo (kodie-ypg / Kodie-YPG).
2. Re-upload ALL files in this zip over the existing ones (Replace):
   - Add file -> Upload files -> drag everything (index.html, assets/, icons/, logo.png, manifest.json, sw.js, apple-touch-icon.png, favicon.ico)
   - Files with the same name will overwrite. Commit changes.
3. If you already enabled Pages (Settings -> Pages -> Branch main / (root)), nothing else is needed.
4. Hard-refresh the site (Ctrl+Shift+R). The logo and home-screen icon are fixed now.

IMPORTANT: You MUST re-upload the replaced files - the previous logo/icon set was blank (transparent).

