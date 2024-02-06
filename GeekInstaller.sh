#!/bin/bash

function postgresql_install() {
	echo ""
	if [[ $EUID -ne 0 ]]; then
		clear
		echo "This script must be run as root or with sudo privileges."
	else

		if command -v psql &>/dev/null; then
			clear
			echo "PostgreSQL is already installed."
		else
			echo -e "\nInitializing Process"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y
			### Adding repositories and keys, removing old repositories
			echo -e "\nRemoving previous repositories for PostgreSql"
			sudo rm /etc/apt/sources.list.d/pgdg*
			echo -e "\nAdding latests repositores"
			# Adding Repositories
			sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
			# Import the repository signing key:
			wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -			
			sleep 2s			
			clear
			### Updating System
			echo -e "\nUpdating system"
			sudo apt update -y
			sudo apt upgrade -y
			sudo apt-get autoremove -y
			echo -e "\nSystem updated"
			sleep 2s			
			clear
			### Installing Latest Version
			echo -e "\nInstalling PostgreSql latest version"
			sudo apt install postgresql postgresql-contrib -y
			echo -e "\nPostgreSQL Installed\n"
			sleep 2s
			clear
			# Change the main password for the administrator
			echo -e "\nAdmin password and New user and database creation"
			echo -e "\nEnter the new password for the PostgreSQL administrator (postgres user):"
			read admin_password
			sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$admin_password'"
			sleep 2s
			clear
			# Allow access from every network
			echo -e "Modifying PostgreSQL configuration to allow access from every network..."
			echo -e "\nModifying postgresql.conf"
			echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/postgresql.conf
			echo -e "\nModifying pg_hba.conf"
			echo "host    all             all             0.0.0.0/0               scram-sha-256" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf
			echo -e "\nConfiguration files changed"			
			echo -e "\nRestarting PostgreSql service"
			# Reload PostgreSQL to apply changes
			sudo service postgresql restart
			clear
			echo -e "\n\nPostgreSQL setup completed!\n\n"
			service postgresql status
		fi
	fi
   	echo ""
}


function postgresql_install_with_intitial_script() {
	echo ""
	if [[ $EUID -ne 0 ]]; then
		clear
		echo "This script must be run as root or with sudo privileges."
	else

		if command -v psql &>/dev/null; then
			clear
			echo "PostgreSQL is already installed."
		else
			echo -e "\nInitializing Process"
			sudo apt update -y
			sudo apt upgrade -y
			sudo apt autoremove -y
			### Adding repositories and keys, removing old repositories
			echo -e "\nRemoving previous repositories for PostgreSql"
			sudo rm /etc/apt/sources.list.d/pgdg*
			echo -e "\nAdding latests repositores"
			# Adding Repositories
			sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
			# Import the repository signing key:
			wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -			
			sleep 2s			
			clear
			### Updating System
			echo -e "\nUpdating system"
			sudo apt update -y
			sudo apt upgrade -y
			sudo apt autoremove -y
			echo -e "\nSystem updated"
			sleep 2s			
			clear
			### Installing Latest Version
			echo -e "\nInstalling PostgreSql latest version"
			sudo apt install postgresql postgresql-contrib -y
			echo -e "\nPostgreSQL Installed\n"
			sleep 2s
			clear
			# Change the main password for the administrator
			echo -e "\nAdmin password and New user and database creation"
			echo -e "\nEnter the new password for the PostgreSQL administrator (postgres user):"
			read admin_password
			sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$admin_password'"
			sleep 2s
			clear
			# Create a new user and database
			echo "Enter the name of the new user:"
			read new_username
			echo -e "\nEnter the password for the new user:"
			read new_user_password
			sudo -u postgres psql -c "CREATE USER $new_username WITH PASSWORD '$new_user_password';"
			echo -e "\nEnter the name for the intial database:"
			read new_data_base
			sudo -u postgres psql -c "CREATE DATABASE $new_data_base;"
			sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $new_data_base TO $new_username;"
			echo -e "\nUsers and DataBase created"
			sleep 2s
			clear
			# Allow access from every network
			echo -e "Modifying PostgreSQL configuration to allow access from every network..."
			echo -e "\nModifying postgresql.conf"
			echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/postgresql.conf
			echo -e "\nModifying pg_hba.conf"
			echo "host    all             all             0.0.0.0/0               scram-sha-256" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf
			echo -e "\nConfiguration files changed"
			#sleep 1s
			echo -e "\nRestarting PostgreSql service"
			# Reload PostgreSQL to apply changes
			sudo service postgresql restart
			sleep 2s
			clear
			# Run the SQL script
			echo -e "Running init.sql"
			echo -e "You can place your SQL commands in the init.sql file."
			echo -e "Press Enter to continue when ready..."
			read
			sudo -u postgres psql -d $new_data_base -a -f init.sql
			echo -e "\nScript processed"
			clear
			echo -e "\n\nPostgreSQL setup completed\n\n"
			service postgresql status
		fi
	fi
   	echo ""
}



function mongodb_install_with_access_control() {
	echo ""
        if [[ $EUID -ne 0 ]]; then
                clear
                echo "This script must be run as root or with sudo privileges."
        else

		if command -v mongod &>/dev/null; then
			echo "MongoDB is already installed."
			# Add your code here to run when MongoDB is installed
		else
            echo -e "\nInitializing Process"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y		
			sudo apt-get install gnupg curl
			### Adding repositories and keys, removing old repositories
			echo -e "\nRemoving previous repositories for Mongo"
			sudo rm /etc/apt/sources.list.d/mongodb*
			#curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o -y /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
			curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
			#echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
			echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
			sleep 2s			
			clear
			echo -e "\nUpdating system"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y
			echo -e "\nSystem updated"
			sleep 2s			
			clear
			echo -e "\nInstalling MongoDB latest version"
			sudo apt install -y mongodb-org
			echo -e "\nMongoDB Installed\n"
			sleep 2s
			clear
			# Start MongoDB service
			echo "Starting MongoDB service..."
			sudo systemctl daemon-reload
			systemctl start mongod
			# Enable MongoDB to start on boot
			echo "Enabling MongoDB to start on boot..."
			systemctl enable mongod
			sleep 2s
			clear
			# Mongo defalut connection
			HOST="localhost"        # MongoDB host
			PORT="27017"            # MongoDB port
			DB_ADMIN="admin"        # Admin database
			# Prompt for the admin password
			read -s -p "Enter the admin password: " admin_password
			echo
			# Create an admin user with the provided password
			echo "Creating admin user"
			# Creating js file for adding user
			echo "use admin" > create_admin_user.js
			echo "db.createUser({ user: 'admin', pwd: '$admin_password', roles: [{role: 'userAdminAnyDatabase', db: 'admin'],{role: 'readWriteAnyDatabase', db: 'admin'}] })" >> create_admin_user.js
			mongosh --host "$HOST:$PORT" "$DB_ADMIN" create_admin_user.js
			# Deleting js file
			rm create_admin_user.js
			echo "Admin User created"
			# Configure MongoDB to require authentication
			echo "Configuring MongoDB to require authentication..."
			echo 'security.authorization: enabled' >> /etc/mongod.conf
			sleep 2s
			clear
			# Update MongoDB to bind to all IP addresses (0.0.0.0)
			echo "Updating MongoDB to bind to all IP addresses..."
			sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

			# Restart MongoDB to apply the authentication settings
			echo "Restarting MongoDB..."
			systemctl restart mongod

			echo -e "\n\nMongoDB installation and admin password setup completed."
			echo "Admin user: admin"
			echo -e "Admin password: $admin_password\n\n"
			sudo service mongod status

		fi
	fi

	echo ""
}

function mongodb_install() {
	echo ""
        if [[ $EUID -ne 0 ]]; then
                clear
                echo "This script must be run as root or with sudo privileges."
        else

		if command -v mongod &>/dev/null; then
			echo "MongoDB is already installed."
			# Add your code here to run when MongoDB is installed
		else
            echo -e "\nInitializing Process"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y		
			sudo apt-get install gnupg curl
			### Adding repositories and keys, removing old repositories
			echo -e "\nRemoving previous repositories for Mongo"
			sudo rm /etc/apt/sources.list.d/mongodb*
			#curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o -y /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
			curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
			#echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
			echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
			sleep 2s			
			clear
			echo -e "\nUpdating system"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y
			echo -e "\nSystem updated"
			sleep 2s			
			clear
			echo -e "\nInstalling MongoDB latest version"
			sudo apt install -y mongodb-org
			echo -e "\nMongoDB Installed\n"
			sleep 2s
			clear
			# Start MongoDB service
			echo "Starting MongoDB service..."
			sudo systemctl daemon-reload
			systemctl start mongod
			# Enable MongoDB to start on boot
			echo "Enabling MongoDB to start on boot..."
			systemctl enable mongod
			sleep 2s
			clear
			# Update MongoDB to bind to all IP addresses (0.0.0.0)
			echo "Updating MongoDB to bind to all IP addresses..."
			sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
			# Restart MongoDB to apply the authentication settings
			echo "Restarting MongoDB..."
			systemctl restart mongod
			clear
			echo -e "\n\nMongoDB installation completed\n\n"
			sudo service mongod status
		fi
	fi

	echo ""
}

function haproxy_install() {
	echo ""
        if [[ $EUID -ne 0 ]]; then
                clear
                echo "This script must be run as root or with sudo privileges."
        else

		if command -v haproxy &>/dev/null; then
			echo "HaProxy is already installed."
			# Add your code here to run when MongoDB is installed
		else
            echo -e "\nUpdating system"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y
			echo -e "\nSystem updated"
			echo -e "\nInstalling HaProxy latest version"
			sudo apt-get install haproxy -y
			clear
			echo -e "\n\nHaProxy installation completed."
			sudo service haproxy status
		fi
	fi

	echo ""
}


function postgresql_uninstall() {
	echo ""
        if [[ $EUID -ne 0 ]]; then
                clear
                echo "This script must be run as root or with sudo privileges."
        else

		if command -v psql &>/dev/null; then
			echo "Uninstalling PosrgreSQL"
			echo "Backing Up Data"
			sudo cp -R /var/lib/postgresql /var/lib/postgresql_backup
			echo "Disabling PostgreSQL Services"
			sudo systemctl disable postgresql
			sudo apt-get remove postgresql* -y
			sudo apt-get purge postgresql* -y
			sudo apt-get autoremove -y
			echo -e "\nDeleting additional files and repositories"
			sudo rm -rf /etc/postgresql
			sudo rm -rf /var/lib/postgresql
			sudo rm -rf /var/log/postgresql
			sudo rm /etc/apt/sources.list.d/pgdg*
			sudo apt-key del B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
			sudo userdel -f postgres
			clear
			echo -e "\n\nPostgreSQL Uninstalled"
		else
			echo "PostgreSQL is not installed"
		fi
	fi
	echo ""
}

function mongodb_uninstall() {
	echo ""
        if [[ $EUID -ne 0 ]]; then
                clear
                echo "This script must be run as root or with sudo privileges."
        else

		if command -v mongod &>/dev/null; then
			echo -e "\nUninstalling Mongo."
			sudo apt remove mong* -y
			sudo apt purge mong* -y
			sudo apt autoremove -y
			echo -e "\nDeleting additional files and repositories"
			sudo rm -R /var/lib/mongodb
			sudo rm -R /var/log/mongodb
			sudo rm /etc/apt/sources.list.d/mongodb*
			clear
			echo -e "\n\nMongoDB Uninstalled"
		else
			echo "MongoDB is not installed"
		fi
	fi
	echo ""
}


function haproxy_uninstall() {
	echo ""
        if [[ $EUID -ne 0 ]]; then
                clear
                echo "This script must be run as root or with sudo privileges."
        else

		if command -v haproxy &>/dev/null; then
			echo -e "\nUninstalling HaProxy"
			sudo apt-get remove haproxy -y
			sudo apt-get purge haproxy -y
			sudo apt-get autoremove -y
			clear
			echo -e "\n\nHaProxy Uninstalled"
		else
            echo "HaProxy is not installed"		
		fi
	fi
	echo ""
}

function memory_check() {
    echo ""
	echo "Memory usage on ${server_name} is: "
	free -h
	echo ""
}
function cpu_check() {
    echo ""
	echo "CPU load on ${server_name} is: "
    echo ""
	uptime
    echo ""
}
function tcp_check() {
    echo ""
	echo "TCP connections on ${server_name}: "
    echo ""
	cat  /proc/net/tcp | wc -l
    echo ""
}
function kernel_check() {
    echo ""
	echo "Kernel version on ${server_name} is: "
	echo ""
	uname -r
    echo ""
}

function all_checks() {
	memory_check
	cpu_check
	tcp_check
	kernel_check
}
##
# Color  Variables
##
green='\e[32m'
blue='\e[34m'
clear='\e[0m'
##
# Color Functions
##
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

menu(){
#clear
echo -ne "
Installing in $HOSTNAME Options \n\n
$(ColorGreen '1)') Install PostgreSQL
$(ColorGreen '2)') Install PostgreSQL with Initial Script
$(ColorGreen '3)') Install MongoDB
$(ColorGreen '4)') Install MongoDB with Access Control
$(ColorGreen '5)') Install HaProxy
$(ColorGreen '6)') Uninstall PostgreSQL
$(ColorGreen '7)') Uninstall MongoDB
$(ColorGreen '8)') Uninstall HaProxy
$(ColorGreen '9)') Allow sudoers use sudo with no password
$(ColorGreen '10)') Chekc all
$(ColorGreen 'Q)') Exit (Q/q)
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
			1) clear ; postgresql_install ;
			menu ;;
			2) clear ; postgresql_install_with_intitial_script ;
			menu ;;
			3) clear ; mongodb_install ;
			menu ;;
			4) clear ; mongodb_install_with_access_control ;
			menu ;;
			5) clear ; haproxy_install ;
			menu ;;
			6) clear ; postgresql_uninstall ;
			menu ;;
			7) clear ; mongodb_uninstall ;
			menu ;;
			8) clear ; haproxy_uninstall;
			menu ;;
			9) clear ; all_checks ;
			menu ;;
			10) clear ; all_checks ;
			menu ;;
			q) clear ; 
			exit 0 ;;
			Q) clear ; 
			exit 0 ;;
			*) clear ; echo "Wrong option.";
			menu	;;
        esac
}

# Call the menu function
clear
menu
