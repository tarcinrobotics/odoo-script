################################################################################
# Organization : Tarcin Robotic LLP
# Author       : vigneshpandian
################################################################################
#!/bin/bash
# declaration of variables for location storage

conf_file="/etc/nirvagi.conf"
service_file="/etc/systemd/system/nirvagi.service"

config_content="[options]
admin_passwd=nirvagi
db_host=False
db_port=False
db_user=nirvagi
db_password=False
addons_path=/opt/nirvagi/addons,/opt/nirvagi/custom-addons
xmlrpc_port=8069"

service_content="[Unit]
Description=
Requires=postgresql.service
After=network.target postgresql.service
[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=nirvagi
Group=nirvagi
ExecStart=/opt/nirvagi/nirvagi-venv/bin/python3 /opt/nirvagi/odoo-bin -c /etc/nirvagi.conf
StandardOutput=journal+console
[Install]
WantedBy=multi-user.target"
echo "################################################################################"
echo "# Organization : Tarcin Robotic LLP"
echo "# Author       : vigneshpandian"
echo "################################################################################"

# updating server 
echo    "---- UPDATING SERVER ----"

if sudo apt update && sudo apt upgrade -y ; then
    echo "---- updation completed !!! ----"
else
    echo "---- server updation failed ----"
fi

# creating service and config files for odoo
echo "---- CREATING CONFIG AND SERVICE FILES FOR NIRVAGI ----"
# service file
if sudo touch /etc/systemd/system/nirvagi.service ; then
    echo "---- nirvagi.service file has been created !!! ----"
else
    echo "---- failed to create the nirvagi.service file !!! ----"
fi

# conf file
if sudo touch /etc/nirvagi.conf ; then 
    echo "---- nirvagi.conf file has been created !!! ----"
else
    echo "---- failed to create the nirvagi.conf file ----"
fi
# creating and giving permission directories
echo "---- GIVING PERMISSIONS ----"
# creating dir
if sudo mkdir -p /opt/nirvagi ; then
    echo "---- nirvagi directory has been created ----"
else
    echo "---- Failed to create the odoo directory / directory already exists !!! ----"
fi
# giving permission to dir
if sudo chmod u+w /opt/nirvagi ; then
    echo "---- successfully given permission to nirvagi directory ----"
else
    echo "---- Failed to create the nirvagi directory !!! ----"
fi

# installing pre-requisites packages 
echo    "---- INSTALLING PRE-REQUISITES ----"
sudo apt install -y build-essential python3.10 wget python3.10-dev python3-venv python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev postgresql
echo    "---- completed installing pre-requisites !!! ----"

# creating odoo user

echo    "---- Creating nirvagi user ----"

if sudo useradd -m -d /opt/nirvagi -U -r -s /bin/bash nirvagi ; then
    echo    "---- completed creating nirvagi user  !!! ----"
else
    echo "nirvagi user creation failed / the user already exists"
fi

# giving permission to odoo user
if sudo chown -R nirvagi /opt/nirvagi ; then
    echo "---- giving permission to nirvagi user ----"
else
    echo "---- Failed to give permission to nirvagi user ----"
fi
# creating postgres sql user for odoo

echo    "---- Creating Postgresql user for user ----"

if sudo su - postgres -c 'createuser -s nirvagi'; then
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

echo    "---- SWITCHING TO NIRVAGI USER ----"
sudo su - nirvagi  <<EOF


echo    "---- cloning from github ----"


if git clone https://github.com/tarcinrobotics/nirvagi-dev --depth 1 --branch main /opt/nirvagi ; then 
    echo    "---- successfully cloned from github !!! ----"
else
    echo    "---- failed cloning from github / cloned files already present !!! ----"
fi

# configuring odoo
cd /opt/nirvagi
python3 -m venv nirvagi-venv
echo    "---- activating virtual environment "
if source /opt/nirvagi/nirvagi-venv/bin/activate ; then
    echo "---- virtual environment activated successfully !!!"
else
    echo "---- virtual environment failed !!!"
    echo    "---- exiting from script !!! ----"
    exit
fi

# installing requirements for odoo
pip3 install wheel

# installing odoo-requirements.txt file
if pip3 install -r /opt/nirvagi/requirements.txt ; then
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
if mkdir /opt/nirvagi/custom-addons ; then
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
    echo    "---- failed to create nirvagi.conf file ----"
fi

# adding contents to the service file

if echo "$service_content" | sudo tee "$service_file" > /dev/null  ; then
        echo    "---- service file created successfully ----"
else
        echo    "---- failed to create service file ----"
fi

echo "---- file writing completed !!!! ----"
# starting odoo 

echo "---- STARTING ODOO SERVICE ----"
if sudo systemctl enable --now nirvagi ; then
    echo    "---- Nirvagi service has been added in startup----"
else
    echo    "---- Nirvagi service failed in adding in startup----"
fi

if sudo systemctl daemon-reload ; then
    echo "--- Daemon Reloaded successfully !!! ---"
else
    echo "--- failed to reload daemon !!! ---"
fi

if sudo systemctl start nirvagi.service ; then
    echo "--- nirvagi service started successfully !!! ---"
else
    echo "--- failed to start nirvagi service !!! ---"
fi

echo "*** nirvagi has been installed successfully !!! ***"