# cdi-sample-app

Sample application used as the target of demo pull requests for the cross-layer dependency graph tool.
It has three logical repositories in one git repository:

| Folder | What | Origin |
|---|---|---|
| `web/` | Angular client | upstream MIT sample, plus `web/src/synthetic/` |
| `api/` | ASP.NET Core Web API (.NET 10) | upstream MIT sample, plus `api/Synthetic/` and `api/tests/` |
| `db/`  | SQL Server objects | all synthetic |

**Synthetic data.** Anything marked synthetic was written for the proof of concept. Results on this sample say
nothing about accuracy on real code.

Upstream: https://github.com/AnkitSharma-007/CRUD.ASPCore.Angular.WebAPI.ADO @ `938cb17` (MIT, see `LICENSE` and `NOTICE`).
Tool configuration (`.cdi/config.yml`) is added in a later step.
