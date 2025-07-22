#!/bin/bash
set -e
/opt/mssql/bin/sqlservr &

until /opt/mssql-tools18/bin/sqlcmd -U sa -P "$SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null
do
  sleep 2
done

echo "Running init.sql..."
/opt/mssql-tools18/bin/sqlcmd -U sa -P "$SA_PASSWORD" -C -i ./db/init.sql

sleep 5

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
  END
  " 

wait