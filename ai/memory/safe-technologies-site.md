---
name: safe-technologies-site
description: "SAFE Technologies demo marketing site — where it lives, what's unverified in its copy, and the hosting constraint"
metadata: 
  node_type: memory
  type: project
  originSessionId: 16915b61-399f-41bb-8fc0-588158147a10
  modified: 2026-10-22T12:06:46.321Z
---

Password-gated demo marketing site for **SAFE Technologies** (Jose
Alguera-Lara's company; SAFE = Sovereign Agentic Financial Ecosystem, AI agents
for public practice sold as "digital employees"). Built 2026-10-22 from the
ChatGPT-generated brand blueprint Jose emailed to the UTS professors.

- Source: `~/code/projects/safe-site`, git repo, `docker compose up -d` → port 3000, path `/safe`
- Dev build runs on [[omarchy-1-minipc]]; target is `safe.optimisedthought.com`
- Copy is **Jose's brief verbatim**, at PJF's explicit instruction. `PRE-LAUNCH.md`
  in the repo lists every claim needing a source or sign-off.

**Why:** two claims in that copy have no source anywhere in PJF's notes — the
"2×–3×" productivity target and "AI Institute of Australia". UTS and Google are
real relationships but the Google one was still being negotiated as of
2026-10-22. Don't let these harden into assumed facts in later sessions.

**How to apply:**
- ASV Wadeson's real brand is indigo `#2f3786` + coral `#ff4132` + Suisse Int'l.
  The brief's "navy and gold ASVW heritage" is wrong — there is no gold in it.
- Hosting constraint: `optimisedthought.com` DNS is on **Porkbun**, apex and www
  point at GitHub Pages (static, no Node, no basic auth). t480 exposes services
  on its tailnet IP only — no reverse proxy, no public ingress. So a custom
  public domain needs new ingress built; Cloudflare Tunnel would require moving
  the zone off Porkbun.
