# github-workflows

GitHub Actions workflows for different purposes — watchers, scheduled jobs, automation — that run on GitHub instead of on a laptop.

Each job has its own folder with a README (what, why, setup, verification) and its script.
Its workflow file lives in `.github/workflows/`, because GitHub reads workflows only from there.

| Job | Folder | Workflow | What it does |
|---|---|---|---|
| Hetzner CX23 watcher | [`hetzner-cron-job/`](hetzner-cron-job/) | [`hetzner-cx23.yml`](.github/workflows/hetzner-cx23.yml) | Emails once when the CX23 cloud server can be ordered, then stops |

## Adding a job

1. New folder `<job-name>/` with a `README.md` and the script.
2. New workflow `.github/workflows/<job-name>.yml` that checks out only that folder
   (`sparse-checkout: <job-name>`).
3. Secrets the job needs go in repo secrets, prefixed by what they belong to.
4. A row in the table above.
