---
name: railway-custom-domain-acme
description: Attach a Railway custom domain only after its DNS exists, or the ACME failure is cached against that hostname for days
metadata:
  type: reference
---

**Add the DNS records first, then attach the domain in Railway.** Railway begins
Let's Encrypt validation the instant a custom domain is attached. Against a
hostname that does not resolve yet, those attempts fail and Railway caches the
failure **against that hostname**.

Symptoms: `CERTIFICATE_STATUS_TYPE_ISSUE_FAILED`, error "Let's Encrypt rate limit
reached", `retryable: false`.

What does **not** clear it:
- `railway domain certificate retry` — refuses while `retryable: false`
- Deleting and re-adding the domain — a brand-new domain object inherits the
  failed state instantly, with no validation attempt
- Waiting ~10 hours

What does: **about two days**, after which a fresh attach goes straight to
`ISSUING`. Confirmed hostname-scoped, not account-scoped: a different subdomain
on the same service and account validated normally while the blocked one did not.

**Why:** cost a multi-day delay on [[safe-technologies-site]] in October 2026,
plus repeated DNS edits by PJF, because I attached the domain before he had added
the records.

**How to apply:**
- Each delete/re-add rotates the `*.up.railway.app` CNAME target, so DNS goes
  stale every time — but old targets keep routing, so an outdated CNAME can still
  work. Check before asking for a DNS change.
- Railway's error text names a rate limit even when no Let's Encrypt limit is
  near. Check crt.sh for the real issuance history before believing it.
- Verify with `openssl s_client ... | openssl x509 -noout -subject`, not
  Railway's status field.
- Pin `PORT` to match the domain's target port; Railway injects `8080` by
  default, which silently serves 502s if the domain expects another port.
