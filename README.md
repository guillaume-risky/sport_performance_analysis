# Sport Performance Analysis Monorepo

A production-ready monorepo containing a Next.js web application, Spring Boot API, and PostgreSQL database infrastructure.

## Project Structure

```
.
├── web/          # Next.js web application (TypeScript)
├── api/          # Spring Boot API (Java)
└── infra/        # Docker Compose infrastructure
```

## Prerequisites

Before running this project, ensure you have the following installed:

- **Node.js** (v18 or higher) and **npm**
- **Java** (JDK 17 or higher)
- **Maven** (3.6 or higher)
- **Docker** and **Docker Compose**
- **Git**

## Setup Instructions (Windows)

### 1. Clone the Repository

```powershell
git clone <repository-url>
cd sport_performance_analysis
```

### 2. Start PostgreSQL Database

Navigate to the infra directory and start the database:

```powershell
cd infra
docker compose up -d
```

Verify the database is running:

```powershell
docker ps
```

You should see a container named `sport_performance_postgres` running.

### 3. Configure Environment Variables

Copy the example environment files:

```powershell
# From root directory
Copy-Item infra\.env.example infra\.env
Copy-Item web\.env.example web\.env
Copy-Item api\.env.example api\.env
```

Edit the `.env` files if you need to customize the default values.

### 4. Start the API

Open a new terminal window and navigate to the api directory:

```powershell
cd api
mvn clean install
mvn spring-boot:run
```

The API will start on `http://localhost:8080`

### 5. Start the Web Application

Open another terminal window and navigate to the web directory:

```powershell
cd web
npm install
npm run dev
```

The web application will start on `http://localhost:3000`

## Verification

### Verify Database

Check that PostgreSQL is running and accessible:

```powershell
docker exec -it sport_performance_postgres psql -U postgres -d sport_performance -c "SELECT version();"
```

### Verify API Health Endpoint

Using PowerShell (Invoke-WebRequest):

```powershell
Invoke-WebRequest -Uri http://localhost:8080/health -Method GET
```

Or using curl (if available):

```powershell
curl http://localhost:8080/health
```

Expected response:
```json
{"status":"ok"}
```

### Verify Web Application Health Page

Open your browser and navigate to:

```
http://localhost:3000/health
```

You should see a health check page with "Status: OK".

Or using PowerShell:

```powershell
Invoke-WebRequest -Uri http://localhost:3000/health -Method GET
```

## Health Endpoints

- **API Health**: `GET http://localhost:8080/health`
- **Web Health Page**: `http://localhost:3000/health`

## Stopping Services

### Stop Web Application
Press `Ctrl+C` in the web terminal

### Stop API
Press `Ctrl+C` in the API terminal

### Stop Database
```powershell
cd infra
docker compose down
```

To remove volumes (data will be lost):

```powershell
docker compose down -v
```

## Development

### Web Application
- Framework: Next.js 14 with TypeScript
- UI: Glassmorphism design, mobile-first responsive
- Port: 3000

### API
- Framework: Spring Boot 3.2.5
- Language: Java 17
- Port: 8080

### Database
- PostgreSQL 16 (Alpine)
- Port: 5432
- Volume: `sport_performance_postgres_data`
- Migration Tool: Flyway

## Database Migrations

The API uses Flyway for database schema management. Migrations are located in `api/src/main/resources/db/migration/`.

### How Migrations Work

Flyway automatically applies migrations when the Spring Boot application starts. Migration files follow the naming convention:
- `V{version}__{description}.sql` (e.g., `V1__Create_base_tables.sql`)

### Applying Migrations

Migrations are applied automatically when you start the API:

```powershell
cd api
mvn spring-boot:run
```

Flyway will:
1. Check the current database schema version
2. Apply any pending migrations in order
3. Update the `flyway_schema_history` table to track applied migrations

### Verifying Migrations

To verify that migrations have been applied successfully:

```powershell
# Connect to the database
docker exec -it sport_performance_postgres psql -U postgres -d sport_performance

# List all tables
\dt

# Check Flyway migration history
SELECT * FROM flyway_schema_history ORDER BY installed_rank;

# Exit psql
\q
```

### Resetting Local Database

**Warning**: This will delete all data in your local database.

To completely reset the local database:

```powershell
# Stop the database
cd infra
docker compose down -v

# Remove the volume (this deletes all data)
docker volume rm sport_performance_postgres_data

# Start the database again
docker compose up -d

# Start the API to apply migrations
cd ..\api
mvn spring-boot:run
```

Alternatively, you can drop and recreate the database:

```powershell
# Connect to PostgreSQL
docker exec -it sport_performance_postgres psql -U postgres

# Drop and recreate the database
DROP DATABASE sport_performance;
CREATE DATABASE sport_performance;

# Exit psql
\q

# Start the API to apply migrations
cd api
mvn spring-boot:run
```

### Migration Files

The database schema is organized across multiple migration files:

- **V1**: Base tables (Academy, Sport, Team, User, Player)
- **V2**: Positions and Skills tables
- **V3**: Events and Sessions tables
- **V4**: Feedback, Insights, and Transcripts
- **V5**: Reporting tables (Training, Match, Skill, Trial reports, Daily stats, Final reports)
- **V6**: Audit and Security tables (OTP logs, Audit logs, Blocked access attempts)

### Database Schema Principles

- **Multi-tenant isolation**: All tables include `academy_id` for tenant isolation
- **Immutable identity numbers**: Primary linking keys (academy_number, sport_unit_number, team_unit_number, user_number, player_system_number, event_unique_number) are immutable
- **Referential integrity**: Foreign keys enforce relationships between entities
- **Historical versions**: Key records maintain history tables for auditability
- **No coach attribution**: Consolidated insights table does not store coach attribution for player-facing outputs

## Troubleshooting

### Port Already in Use
If port 3000, 8080, or 5432 is already in use:
- Web: Change port in `web/package.json` scripts or use `npm run dev -p 3001`
- API: Change `server.port` in `api/src/main/resources/application.properties`
- Database: Change `POSTGRES_PORT` in `infra/.env`

### Docker Issues
Ensure Docker Desktop is running on Windows. Check with:

```powershell
docker --version
docker compose version
```

### Maven Issues
Ensure Maven is installed and in PATH:

```powershell
mvn --version
```

### Node.js Issues
Ensure Node.js and npm are installed:

```powershell
node --version
npm --version
```
