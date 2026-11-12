# Run the sample application: `make db`, `make api`, `make ui` (each installs what it needs). `make help` lists everything.
API_PORT ?= 5050
API_ENV  ?= Production
UI_PORT  ?= 4200
DB_PORT  ?= 1433
DB_NAME  ?= myTestDB
export DB_PORT DB_NAME

.PHONY: help db db-stop db-reset api ui build-api

help:           ## list the commands
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/^([a-z-]+):.*## (.*)/  make \1\t\2/'

db:             ## SQL Server in Docker: create it, build the database from db/, load sample rows (safe to repeat)
	@bash db/up.sh

db-stop:        ## stop the SQL Server container (data is kept)
	docker stop cdi-sample-sql

db-reset:       ## DELETE the SQL Server container, its data and the saved password; `make db` then starts fresh
	-docker rm -f cdi-sample-sql
	-docker volume rm cdi_sample_sql_data
	rm -f .local/sa-password

api: db         ## the ASP.NET Core api on http://localhost:5050 (starts the database first; restores packages automatically)
	@command -v dotnet >/dev/null || { echo "ERROR: .NET SDK not found. Install .NET 10: https://dotnet.microsoft.com/download"; exit 1; }
	cd api && ASPNETCORE_ENVIRONMENT=$(API_ENV) \
	  ConnectionStrings__DefaultConnection="Server=localhost,$(DB_PORT);Database=$(DB_NAME);User Id=sa;Password=$$(cat ../.local/sa-password);TrustServerCertificate=true" \
	  dotnet run --no-launch-profile --urls http://localhost:$(API_PORT)

ui:             ## the Angular page on http://localhost:4200 (npm install on first run; calls the api via a proxy; start `make api` too)
	@command -v node >/dev/null && command -v npm >/dev/null || { echo "ERROR: Node.js not found. Install Node: https://nodejs.org/"; exit 1; }
	cd web && { [ -d node_modules ] || npm ci --no-audit --no-fund; } && NODE_OPTIONS=--openssl-legacy-provider npx ng serve --proxy-config proxy.conf.json --port $(UI_PORT)

build-api:      ## just compile the api
	cd api && dotnet build -nologo -v q
