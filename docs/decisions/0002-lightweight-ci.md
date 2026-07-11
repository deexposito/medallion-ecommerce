# 0002 — Lightweight CI (`dbt parse`) instead of a data-dependent build

Status: Accepted
Date: 2026-07-12

## Context

CI should catch broken code automatically on every push. The obvious
"complete" version would run `dbt build` for real, which means loading
the actual Olist dataset. But the raw CSVs aren't in this repo (size and
Kaggle license — see ADR 0001), so a full CI build would need to download
them on every run, which means storing Kaggle credentials as a GitHub
secret and adding a network dependency on an external service the CI
doesn't otherwise need.

## Decision

CI runs `dbt parse` only: it validates the whole project (Jinja
templates, `ref()`/`source()` resolution, `schema.yml` syntax) without
executing any SQL or touching real data.

## Alternatives considered

- **Full `dbt build` with a downloaded dataset**: rejected. It would
  catch more (actual data quality regressions, test failures), but ties
  CI's reliability to a third-party service's availability and API
  stability. A CI run failing because Kaggle rate-limited a download, not
  because of a real code problem, is worse for a portfolio piece than a
  narrower but always-reliable check — a red X that isn't the
  contributor's fault erodes trust in the signal.
- **Commit a small sample of the dataset for CI to use**: rejected as
  unnecessary complexity for this project's size; would also risk drifting
  from the real dataset's shape/edge cases (like the `fct_reviews` grain
  issue, which only showed up with the real data).

## Consequences

- CI catches broken refs, invalid YAML, and Jinja errors on every push -
  the most common way this kind of project actually breaks.
- CI does **not** catch data quality regressions or broken business logic
  (e.g. a join that silently drops rows) - those still rely on running
  `dbt build` locally, as done throughout this project.
- If this project ever needed real CI test coverage (e.g. before adding
  collaborators), revisiting the Kaggle-secret approach would be the
  natural next step.
