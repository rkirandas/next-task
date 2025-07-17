#!/bin/bash
/opt/mssql/bin/sqlservr &

echo "Waiting for SQL Server to start..."
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null
do
  sleep 2
done

echo "Running init.sql..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -i /db/init.sql

# Wait so container doesn't exit
wait
