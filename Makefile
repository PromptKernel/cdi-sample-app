# The sample application (Angular web + ASP.NET Core api + SQL Server db) that the cdi tool analyses. Run `make help`.
# Everything configurable is an environment variable with the default shown.
CDI_POC        ?= ../cdi-poc
API_URL        ?= http://localhost:5000
# api/appsettings.json defaults to a Windows SQL Express instance; point this at a SQL Server you run yourself.
DB_CONNECTION  ?=

.PHONY: help build-api run-api install-web run-web analyse analyse-pr serve explorer

help:           ## list the targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/^([a-z-]+):.*## (.*)/  make \1\t\2/'
	@echo; echo "Variables: CDI_POC=$(CDI_POC) API_URL=$(API_URL) DB_CONNECTION=$(if $(DB_CONNECTION),(set),(not set))"

# ---- the application itself (needs .NET 10 SDK, Node, and a SQL Server for the api to run) ----
build-api:      ## compile the ASP.NET Core api (verified to build)
	cd api && dotnet build -nologo -v q

run-api:        ## run the api on API_URL; needs a reachable SQL Server: make run-api DB_CONNECTION="Server=...;Database=...;User Id=...;Password=...;TrustServerCertificate=true" (NOT verified: no SQL Server was used)
	@test -n "$(DB_CONNECTION)" || { echo "set DB_CONNECTION to a SQL Server connection string (appsettings.json points at a Windows SQL Express instance)"; exit 2; }
	cd api && ASPNETCORE_ENVIRONMENT=Development ConnectionStrings__DefaultConnection="$(DB_CONNECTION)" dotnet run --urls $(API_URL)

install-web:    ## npm ci for the Angular client (Angular 8: may need an older Node than the one installed; NOT verified)
	cd web && npm ci

run-web:        ## ng serve the Angular client (NOT verified)
	cd web && npm start

# ---- analyse it with the dependency-intelligence tool in $(CDI_POC) (needs `make setup` there once) ----
analyse:        ## build the dependency baseline of this repository (out/baseline.json here); commit your changes first
	$(MAKE) -C $(CDI_POC) baseline CDI_TARGET=$(abspath .)

analyse-pr:     ## impact report for a branch: make analyse-pr PR=<branch>   (e.g. a local branch you created)
	@test -n "$(PR)" || { echo "usage: make analyse-pr PR=<branch-or-sha>"; exit 2; }
	$(MAKE) -C $(CDI_POC) pr CDI_TARGET=$(abspath .) PR=$(PR)

serve:          ## terminal 1: the tool's read-only API over this repository's baseline
	$(MAKE) -C $(CDI_POC) serve CDI_TARGET=$(abspath .)

explorer:       ## terminal 2: the tool's graph explorer (open the URL it prints)
	$(MAKE) -C $(CDI_POC) web
