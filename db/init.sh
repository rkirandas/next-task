#!/bin/bash
set -e
/opt/mssql/bin/sqlservr &

until /opt/mssql-tools18/bin/sqlcmd -U sa -P "$SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null
do
  sleep 2
done

echo "Checking DB exists"
DB_EXISTS=$(/opt/mssql-tools18/bin/sqlcmd -U sa -P "$SA_PASSWORD" -C -h -1 -W -Q "SELECT COUNT(*) FROM sys.databases WHERE name = '$DB'")

DB_EXISTS=$(echo $DB_EXISTS | xargs)

if [ "$DB_EXISTS" -eq "0" ]; then
  echo "Database '$DB' does not exist. Running init.sql..."
  /opt/mssql-tools18/bin/sqlcmd -U sa -P "$SA_PASSWORD" -C -i ./db/init.sql
  sleep 5
else
  echo "Database '$DB' already exists. Skipping init.sql."
fi

/opt/mssql-tools18/bin/sqlcmd -U sa -P "$SA_PASSWORD" -C -Q "
  IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = '$USER')
  BEGIN
      CREATE LOGIN [$USER] WITH PASSWORD = '$PASSWORD';
  END
  GO

  USE [$DB];
  IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$USER')
  BEGIN
      CREATE USER [$USER] FOR LOGIN [$USER];
      ALTER ROLE db_datareader ADD MEMBER [$USER];
      ALTER ROLE db_datawriter ADD MEMBER [$USER];
      GRANT EXECUTE TO [$USER];
  END
  " 

wait