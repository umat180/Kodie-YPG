import "dotenv/config";
import express from "express";
import cors from "cors";
import fs from "fs";
import path from "path";
import https from "https";
import { exec } from "child_process";
import { fileURLToPath } from "url";
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();

const PORT = process.env.PORT || 8083;
const ROOT = __dirname;
const DEPLOYED = path.join(ROOT, "dist");
const BMS_URL = process.env.BMS_URL || "https://api.mnotify.com";
let BMS_KEY = process.env.BMS_API_KEY || "";

app.use(cors());
app.use(express.json());

const envPath = path.join(ROOT, ".env");
if (fs.existsSync(envPath)) {
  const content = fs.readFileSync(envPath, "utf8");
  const match = content.match(/BMS_API_KEY=(.+)/);
  if (match) BMS_KEY = match[1].trim();
}

function requestBMS(method, endpointWithQuery, body, isJson) {
  return new Promise((resolve, reject) => {
    const url = new URL(BMS_URL + endpointWithQuery);
    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      port: 443,
      method,
      headers: Object.assign(
        {
          Accept: "application/json",
          "Content-Length": 0
        },
        isJson ? { "Content-Type": "application/json" } : {}
      )
    };
    let data = null;
    if (isJson && body) {
      data = JSON.stringify(body);
      options.headers["Content-Length"] = Buffer.byteLength(data);
    }
    const req = https.request(options, (res) => {
      let resp = "";
      res.on("data", (c) => (resp += c));
      res.on("end", () => {
        try {
          resolve(JSON.parse(resp));
        } catch {
          resolve(resp);
        }
      });
    });
    req.on("error", reject);
    if (data) req.write(data);
    req.end();
  });
}

function resolveKey(req) {
  const key = (req.query && req.query.key) || (req.body && req.body.key) || BMS_KEY;
  return key || null;
}

function requireKey(req, res) {
  const key = resolveKey(req);
  if (!key) {
    res.status(400).json({ error: "BMS API key not set. Set it in .env, /api/settings, or pass ?key=" });
    return null;
  }
  return key;
}

app.get("/api/balance/sms", async (req, res) => {
  const key = requireKey(req, res);
  if (!key) return;
  try {
    const r = await requestBMS("GET", "/api/balance/sms?key=" + encodeURIComponent(key));
    res.json(r);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/balance/voice", async (req, res) => {
  const key = requireKey(req, res);
  if (!key) return;
  try {
    const r = await requestBMS("GET", "/api/balance/voice?key=" + encodeURIComponent(key));
    res.json(r);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/api/sms/bulk", async (req, res) => {
  const key = requireKey(req, res);
  if (!key) return;
  const { recipient, message, sender } = req.body || {};
  if (!recipient || !message) return res.status(400).json({ error: "recipient and message required" });
  try {
    const r = await requestBMS(
      "POST",
      "/api/sms/quick?key=" + encodeURIComponent(key),
      { recipient, sender, message, is_schedule: "false", schedule_date: "" },
      true
    );
    res.json(r);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/api/voice/bulk", (req, res) => {
  const key = requireKey(req, res);
  if (!key) return;
  const mp = (req.body && req.body.multipart) || null;
  if (!mp) return res.status(400).json({ error: "multipart payload required" });

  const fields = mp.fields || {};
  const files = mp.files || [];
  const boundary = "----kodiemail" + Date.now().toString(36);
  const chunks = [];
  const push = (b) => chunks.push(Buffer.isBuffer(b) ? b : Buffer.from(b));

  Object.keys(fields).forEach((k) => {
    const v = fields[k];
    const vals = Array.isArray(v) ? v : [v];
    vals.forEach((item) => {
      push(`--${boundary}\r\nContent-Disposition: form-data; name="${k}"\r\n\r\n${item}\r\n`);
    });
  });
  files.forEach((f) => {
    const b64 = f.dataBase64 || "";
    push(`--${boundary}\r\nContent-Disposition: form-data; name="${f.name}"; filename="${f.filename}"\r\nContent-Type: ${f.contentType || "audio/wav"}\r\n\r\n`);
    push(Buffer.from(b64, "base64"));
    push("\r\n");
  });
  push(`--${boundary}--\r\n`);
  const body = Buffer.concat(chunks);

  const url = new URL(BMS_URL + "/api/voice/quick?key=" + encodeURIComponent(key));
  const options = {
    hostname: url.hostname,
    path: url.pathname + url.search,
    port: 443,
    method: "POST",
    headers: {
      "Content-Type": "multipart/form-data; boundary=" + boundary,
      Accept: "application/json",
      "Content-Length": body.length
    }
  };
  const bmsReq = https.request(options, (res) => {
    let resp = "";
    res.on("data", (c) => (resp += c));
    res.on("end", () => {
      try {
        const parsed = JSON.parse(resp);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(parsed));
      } catch {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ response: resp }));
      }
    });
  });
  bmsReq.on("error", (e) => {
    res.status(500).json({ error: e.message });
  });
  bmsReq.write(body);
  bmsReq.end();
});

app.get("/api/settings", (req, res) => res.json({ bmsKeySet: BMS_KEY.length > 0 }));

app.post("/api/settings", (req, res) => {
  const { key } = req.body || {};
  if (!key) return res.status(400).json({ error: "key required" });
  BMS_KEY = key;
  let content = "";
  if (fs.existsSync(envPath)) content = fs.readFileSync(envPath, "utf8");
  if (content.includes("BMS_API_KEY=")) content = content.replace(/BMS_API_KEY=.+/, `BMS_API_KEY=${key}`);
  else content += `\nBMS_API_KEY=${key}\n`;
  fs.writeFileSync(envPath, content);
  res.json({ success: true });
});

if (fs.existsSync(DEPLOYED)) {
  app.use(express.static(DEPLOYED));
  app.get(/^(?!\/api).*/, (req, res) => res.sendFile(path.join(DEPLOYED, "index.html")));
}

app.listen(PORT, () => {
  console.log(`Kodie YPG running at http://localhost:${PORT}`);
  try {
    exec("start http://localhost:" + PORT);
  } catch (e) {}
});