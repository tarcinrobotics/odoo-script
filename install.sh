################################################################################
# Organization : Tarcin Robotic LLP
# Author       : vigneshpandian
################################################################################
#!/bin/bash
# declaration of variables for location storage

conf_file="/etc/odoo.conf"
service_file="/etc/systemd/system/odoo.service"

config_content="[options]
admin_passwd=odoo
db_host=False
db_port=False
db_user=odoo
db_password=False
addons_path=/opt/odoo16/odoo/addons,/opt/odoo/odoo-custom-addons
xmlrpc_port=8069"

service_content="[Unit]
Description=Odoo
Requires=postgresql.service
After=network.target postgresql.service
[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo/odoo-venv/bin/python3 /opt/odoo16/odoo/odoo-bin -c /etc/odoo.conf
StandardOutput=journal+console
[Install]
WantedBy=multi-user.target"
echo "################################################################################"
echo "# Organization : Tarcin Robotic LLP"
echo "# Author       : vigneshpandian"
echo "################################################################################"
echo "ODOO16 has been installed successfully !!! "

# updating server 
echo    "---- UPDATING SERVER ----"

if sudo apt update && sudo apt upgrade -y ; then
    echo "---- updation completed !!! ----"
else
    echo "---- server updation failed ----"
fi

# creating service and config files for odoo
echo "---- CREATING CONFIG AND SERVICE FILES FOR ODOO ----"
# service file
if sudo touch /etc/systemd/system/odoo.service ; then
    echo "---- odoo.service file has been created !!! ----"
else
    echo "---- failed to create the odoo.service file !!! ----"
fi

# conf file
if sudo touch /etc/odoo.conf ; then 
    echo "---- odoo.conf file has been created !!! ----"
else
    echo "---- failed to create the odoo.conf file ----"
fi
# creating and giving permission directories
echo "---- GIVING PERMISSIONS ----"
# creating dir
if sudo mkdir -p /opt/odoo16/odoo ; then
    echo "---- odoo directory has been created ----"
else
    echo "---- Failed to create the odoo directory / directory already exists !!! ----"
fi
# giving permission to dir
if sudo chmod u+w /opt/odoo16 ; then
    echo "---- successfully given permission to odoo directory ----"
else
    echo "---- Failed to create the odoo directory !!! ----"
fi

# installing pre-requisites packages 
echo    "---- INSTALLING PRE-REQUISITES ----"
sudo apt install -y build  ssential wget python3-dev python3-venv python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev postgresql
echo    "---- completed installing pre-requisites !!! ----"

# creating odoo user

echo    "---- Creating Odoo user ----"

if sudo useradd -m -d /opt/odoo -U -r -s /bin/bash odoo ; then
    echo    "---- completed creating odoo user  !!! ----"
else
    echo "odoo user creation failed / the user already exists"
fi

# giving permission to odoo user
if sudo chown -R odoo /opt/odoo16 ; then
    echo "---- giving permission to odoo user ----"
else
    echo "---- Failed to give permission to odoo user ----"
fi
# creating postgres sql user for odoo

echo    "---- Creating Postgresql user for user ----"

if sudo su - postgres -c 'createuser -s odoo'; then
    echo    "---- completed creating postgresql user !!! ----"
else
    echo    "postgersql user creation failed !!!"
fi

# installation of wkhtmltopdf    
echo    "---- Downloading wkhtmltopdf ----"

# installing wkhtmltopdf

if sudo apt install wkhtmltopdf -y ; then
    echo    "---- completed installing wkhtmltopdf !!! ----"
else
    echo    "---- failed installing wkhtmltopdf !!! ----"
fi

# installation and configuration of odoo

echo    "---- SWITCHING TO ODOO USER ----"
sudo su - odoo  <<EOF


echo    "---- cloning from github ----"


if git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 /opt/odoo16/odoo ; then 
    echo    "---- successfully cloned from github !!! ----"
else
    echo    "---- failed cloning from github / cloned files already present !!! ----"
fi

# configuring odoo
cd /opt/odoo
python3 -m venv odoo-venv
echo    "---- activating virtual environment "
if source /opt/odoo/odoo-venv/bin/activate ; then
    echo "---- virtual environment activated successfully !!!"
else
    echo "---- virtual environment failed !!!"
    echo    "---- exiting from script !!! ----"
    exit
fi

# installing requirements for odoo
pip3 install wheel

# installing odoo-requirements.txt file
if pip3 install -r /opt/odoo16/odoo/requirements.txt ; then
    echo "---- requirements installed successfully !!!"
else
    echo "---- requirements installation failed !!!"
    echo    "---- exiting from script !!! ----"
    exit
fi

# deactivating the environment

if deactivate ; then
    echo    "---- virtual environment deactivated and proceeding to next.... ----"
else
    echo    "---- virtual environment not deactivated !!! ----"
fi

# creating custom-addons

echo    "---- creating custom-addons directory----"
if mkdir /opt/odoo/odoo-custom-addons ; then
    echo    "---- custom-addons directory has been created successfully !!! ----"
else
    echo    "---- directory creation failed / directory already available !!!"
fi

# exiting from odoo user

echo    "---- exiting from odoo user ----"

if exit ; then
    echo    "---- exited from odoo user !!! ----"
else
    echo    "---- exiting from odoo user failed !!! ----"
fi 
EOF

# adding contents to the config file
echo "---- WRITING CONFIG AND SERVICE FILES ----"

if  echo "$config_content" | sudo tee "$conf_file" > /dev/null ; then
    echo    "---- config file created successfully ----"
else
    echo    "---- failed to create odoo.conf file ----"
fi

# adding contents to the service file

if echo "$service_content" | sudo tee "$service_file" > /dev/null  ; then
        echo    "---- service file created successfully ----"
else
        echo    "---- failed to create service file ----"
fi

echo "---- writing completed !!!! ----"
# starting odoo 

echo "---- STARTING ODOO SERVICE ----"
if sudo systemctl enable --now odoo ; then
    echo    "---- Odoo service has been added in startup----"
else
    echo    "---- odoo service failed in adding in startup----"
fi

if sudo systemctl daemon-reload ; then
    echo "--- Daemon Reloaded successfully !!! ---"
else
    echo "--- failed to reload daemon !!! ---"
fi

if sudo systemctl start odoo.service ; then
    echo "--- odoo service started successfully !!! ---"
else
    echo "--- failed to start odoo service !!! ---"
fi

if sudo systemctl status odoo.service ; then
    echo "--- odoo status !!! ---"
else
    echo "--- there is no service named odoo !!! ---"
fi


