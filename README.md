# cdi-sample-app

A small employee-management application with three parts:

| Folder | What |
|---|---|
| `web/` | Angular client (the web page) |
| `api/` | ASP.NET Core Web API (.NET 10) (the server) |
| `db/`  | SQL Server scripts: tables, stored procedures, a view (the database) |

Based on https://github.com/AnkitSharma-007/CRUD.ASPCore.Angular.WebAPI.ADO @ `938cb17` (MIT, see `LICENSE` and `NOTICE`).
The upstream project ships no SQL files; everything under `db/` was written for this repository.

Commands: `make help`.
