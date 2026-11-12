# github-workflows

GitHub Actions workflows for different purposes — watchers, scheduled jobs, automation — that run on GitHub instead of on a laptop.

Each job has its own folder with a README (what, why, setup, verification) and its script.
Its workflow file lives in `.github/workflows/`, because GitHub reads workflows only from there.

| Job | Folder | Workflow | What it does |
|---|---|---|---|
| Hetzner CX23 watcher | [`hetzner-cron-job/`](hetzner-cron-job/) | [`hetzner-cx23.yml`](.github/workflows/hetzner-cx23.yml) | Emails once when the CX23 cloud server can be ordered, then stops |

## Many workflows, one repo

Every YAML file in `.github/workflows/` is its own workflow:

- **Own triggers** — each file has its own `on:` (cron, manual button, push…).
- **Own permissions and concurrency** — `permissions:` and `concurrency:` apply to that file
  only. The Hetzner watcher's `actions: write` is not given to other jobs.
- **Own switch** — `gh workflow disable <name>` stops one workflow; the rest keep running.
- **Own history** — the Actions tab lists runs per workflow.

Shared across the repo:

- **Secrets** — every workflow *can* read every repo secret, but only gets the ones it names as
  `${{ secrets.X }}`. Name secrets after their owner (`HCLOUD_TOKEN`, `<JOB>_…`) so it is clear
  which job needs which.
- **The 60-day rule** — in a public repo, GitHub disables scheduled workflows after 60 days
  without repository activity. Activity is counted for the whole repo, so any commit keeps all
  schedules alive.
- **Public logs** — this repo is public, so run logs are public. Secrets show as `***`; scripts
  must never print a token, a password or a mail address.

## Adding a job

1. New folder `<job-name>/` with a `README.md` and the script.
2. New workflow `.github/workflows/<job-name>.yml` that checks out only that folder
   (`sparse-checkout: <job-name>`).
3. Secrets the job needs go in repo secrets, prefixed by what they belong to.
4. A row in the table above.
