#!/bin/bash
# Create the file repository configuration:
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# Install PostgreSQL
sudo apt update -y
sudo apt install postgresql postgresql-contrib -y

# Change the main password for the administrator
echo "Enter the new password for the PostgreSQL administrator (postgres user):"
read admin_password
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$admin_password'"


# Create a new user and database
echo "Enter the name of the new user:"
read new_username
echo "Enter the password for the new user:"
read new_user_password
sudo -u postgres psql -c "CREATE USER $new_username WITH PASSWORD '$new_user_password';"

echo "Enter the name for the intial datbase:"
read new_data_base
sudo -u postgres psql -c "CREATE DATABASE $new_data_base;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $new_data_base TO $new_username;"


# Allow access from every network
echo "Modifying PostgreSQL configuration to allow access from every network..."
echo "Modifying postgresql.conf"
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/postgresql.conf
echo "Modifying pg_hba.conf"
echo "host  all  all  0.0.0.0/0  scram-sha-256" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf

# Reload PostgreSQL to apply changes
sudo service postgresql restart

# Run the SQL script
#echo "Running init.sql..."
#echo "You can place your SQL commands in the init.sql file."
#echo "Press Enter to continue when ready..."
#read
#sudo -u postgres psql -d skully -a -f init.sql

# Done
echo "PostgreSQL setup completed!"
