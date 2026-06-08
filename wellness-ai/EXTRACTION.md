# Extracting Wellness AI into its own project

Right now Wellness AI lives inside the Tayyibat repo under `wellness-ai/`. It is
**fully self-contained** (own `.gitignore`, `app/`, `backend/`, `docs/`) so it
lifts out cleanly into a standalone repo + a separate Claude Code project.

Pick **Option A** (fresh, simplest) or **Option B** (preserve git history).

---

## Option A — Fresh standalone repo (recommended, simplest)

On your Mac:

```bash
# 1. Copy the folder out of the Tayyibat repo to a sibling location
cp -R ~/anthropic-claude-/wellness-ai ~/wellness-ai
cd ~/wellness-ai

# 2. Make it a git repo
git init -b main
git add .
git commit -m "chore: import Wellness AI scaffold (BRD, PRD, app, backend)"
```

Then create the GitHub repo and push. With the GitHub CLI:

```bash
gh repo create wellness-ai --private --source=. --remote=origin --push
```

…or create an empty `wellness-ai` repo in the GitHub UI, then:

```bash
git remote add origin https://github.com/<you>/wellness-ai.git
git push -u origin main
```

> If you want it under a **GitHub org/group** (e.g. a "Wellness AI" org), create
> the repo inside that org: `gh repo create <org>/wellness-ai --private …`.

---

## Option B — Preserve the git history of just these files

If you want the commits that created `wellness-ai/` to come along:

```bash
cd ~/anthropic-claude-

# Split the subdirectory into its own branch with history
git subtree split --prefix=wellness-ai -b wellness-ai-only

# Create the new repo from that branch
mkdir ~/wellness-ai && cd ~/wellness-ai
git init -b main
git pull ~/anthropic-claude- wellness-ai-only

# Push to the new remote
gh repo create wellness-ai --private --source=. --remote=origin --push
```

(Optional) remove it from the Tayyibat repo afterward:

```bash
cd ~/anthropic-claude-
git rm -r wellness-ai
git commit -m "chore: move Wellness AI to its own repo"
git push
```

---

## Start a new Claude Code project from the new repo

Claude Code organizes work by repository/environment. Once `wellness-ai` is its
own GitHub repo:

**Claude Code on the web (claude.com/code):**
1. New environment → connect the `wellness-ai` GitHub repo.
2. Choose the network policy + any env vars / setup script you need
   (e.g. a setup script that runs `cd app && flutter pub get`).
3. Start a session — it clones `wellness-ai`, and this becomes a clean project
   conversation scoped to Wellness AI only.
   Docs: https://code.claude.com/docs/en/claude-code-on-the-web

**Claude Code CLI (local):**
```bash
cd ~/wellness-ai
claude            # starts a session rooted in the Wellness AI repo
```

**Seed the new project's memory:** add a `CLAUDE.md` at the repo root (same
pattern as Tayyibat's) summarizing the product, stack, and the
`docs/` BRD/PRD/architecture so any new session is oriented instantly. The
`docs/` folder already contains everything needed to write it.

---

## What carries over

```
wellness-ai/
├── README.md               # product index + thesis + feature ideas
├── EXTRACTION.md           # this file
├── .gitignore
├── docs/
│   ├── BRD.md              # business requirements
│   ├── PRD.md              # product requirements
│   ├── COMPETITIVE-ANALYSIS.md
│   └── ARCHITECTURE.md     # technical architecture
├── app/                    # Flutter scaffold (consumer surface)
│   ├── pubspec.yaml
│   ├── lib/…               # main, app, config, theme, models, services, features
│   └── README.md
└── backend/                # Supabase scaffold
    ├── sql/0001_init.sql
    ├── functions/analyze/, provider-link/
    └── README.md
```

After extraction, the immediate build path is **PRD §15 (MVP scope)** and the
**8 open questions in PRD §17** (meal-recognition build-vs-buy, regional pricing,
aggregator choice, MVP conditions, data residency).
