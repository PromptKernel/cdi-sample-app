# The sample application (Angular web + ASP.NET Core api + SQL Server db). Run `make help`.
API_URL        ?= http://localhost:5000
# api/appsettings.json defaults to a Windows SQL Express instance; point this at a SQL Server you run yourself.
DB_CONNECTION  ?=

.PHONY: help build-api run-api install-web run-web

help:           ## list the targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/^([a-z-]+):.*## (.*)/  make \1\t\2/'

build-api:      ## compile the ASP.NET Core api
	cd api && dotnet build -nologo -v q

run-api:        ## run the api on API_URL; needs a SQL Server: make run-api DB_CONNECTION="Server=...;Database=...;User Id=...;Password=...;TrustServerCertificate=true"
	@test -n "$(DB_CONNECTION)" || { echo "set DB_CONNECTION to a SQL Server connection string"; exit 2; }
	cd api && ASPNETCORE_ENVIRONMENT=Development ConnectionStrings__DefaultConnection="$(DB_CONNECTION)" dotnet run --urls $(API_URL)

install-web:    ## npm ci for the Angular client (Angular 8: may need an older Node than the newest)
	cd web && npm ci

run-web:        ## ng serve the Angular client
	cd web && npm start
