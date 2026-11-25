# Runbook: change a GitHub or Cloudflare setting through this repo

**Ticket:** FLYERS-16
**Who runs it:** Randall, or anyone who maintains the club platform
**Where:** browser (GitHub web UI)

Settings for the org and its repos are code now. Changing one in the GitHub or Cloudflare dashboard by hand will show up as a difference on the next plan, and the repo wins.

## Steps

1. Open `terraform/managed.auto.tfvars` on GitHub and click the pencil (Edit).
2. Change the value. For example, to turn on the wiki for a repo, set `has_wiki = true` inside that repo's block.
3. Choose **Create a new branch and start a pull request**, then **Propose changes**.
4. Wait for the `plan` check (about a minute). Open it, then read the summary at the bottom of the run page.
   - It should list only the change you made. Anything else, stop and ask Michael.
5. Ask Michael to review. For a change to the website repo, Randall reviews too.
6. After merge, Michael approves the `apply` run in the Actions tab. The change is live when it finishes.

## If it goes wrong

Revert the pull request. The next apply puts the old value back.
