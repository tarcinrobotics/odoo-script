################################################################################
# Organization : Tarcin Robotic LLP
# Author       : vigneshpandian
################################################################################

# updating server 
echo -e "\n---- Updating Server ----"

sudo apt update
sudo apt upgrade -y

# installing pre-requisites packages 
echo -e "\n---- Installing Pre-requisites ----"
sudo apt install -y build-essential wget python3-dev python3-venv python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev postgresql
echo -e "\n---- completed installing pre-requisites !!! ----"

# creating odoo user

echo -e "\n---- Creating Odoo user ----"
if sudo useradd -m -d /opt/odoo -U -r -s /bin/bash odoo ; then
    echo -e "\n---- completed creating odoo user  !!! ----"
else
    echo "odoo user creation failed / the user already exists"
fi

# creating postgres sql user for odoo

echo -e "\n---- Creating Postgresql user for user ----"
if sudo su - postgres -c 'createuser -s odoo'; then
    echo -e "\n---- completed creating postgresql user !!! ----"
else
    echo -e "postgersql user creation failed !!!"
fi

# installation of wkhtmltopdf    

# downloading wkhtmltopdf

echo -e "\n---- Installation of wkhtmltopdf ----"
echo -e "\n\n---- Downloading wkhtmltopdf ----"

if sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb ; then
    echo -e "\n---- completed downloading wkhtmltopdf !!! ----"
else
    echo -e "\n---- failed downloading due to network issues !!! ---- "
fi

# installing wkhtmltopdf

echo -e "\n---- installing wkhtmltopdf ----"

if sudo apt install ./wkhtmltox_0.12.5-1.bionic_amd64.deb ; then
    echo -e "\n---- completed installing wkhtmltopdf !!! ----"
else
    echo -e "\n---- failed installing wkhtmltopdf !!! ----"
fi

# installation and configuration of odoo


sudo su - odoo 
echo -e "\n---- cloning from github ----"
if git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 /opt/odoo16/odoo ; then 
    echo -e "\n---- successfully cloned from github !!! ----"
else
    echo -e "\n---- failed cloning from github !!! ----"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

# configuring odoo
cd /opt/odoo
python3 -m venv odoo-venv
echo -e "\n---- activating virtual environment "
if source odoo-venv/bin/activate ; then
    echo "\n---- virtual environment activated successfully !!!"
else
    echo "\n---- virtual environment failed !!!"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

# installing requirements for odoo
pip3 install wheel

# installing odoo-requirements.txt file
if source pip3 install -r odoo/requirements.txt ; then
    echo "\n---- requirements installed successfully !!!"
else
    echo "\n---- requirements installation failed !!!"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

# deactivating the environment

if deactivate ; then
    echo -e "\n---- virtual environment deactivated and proceeding to next.... ----"
else
    echo -e "\n---- virtual environment not deactivated !!! ----"
fi

# creating custom-addons

echo -e "\n---- creating custom-addons directory----"
if mkdir /opt/odoo/odoo-custom-addons ; then
    echo -e "\n---- custom-addons directory has been created successfully !!! ----"
else
    echo -e "\n---- directory creation failed !!!"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

# exiting from odoo user

echo -e "\n---- exiting from odoo user ----"

if exit ; then
    echo -e "\n---- exited from odoo user !!! ----"
else
    echo -e "\n---- exiting from odoo user failed !!! ----"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

# creating odoo.conf file 

if sudo nano /etc/odoo.conf ; then
    echo -e "\n---- new odoo.conf file has been created !!! ----"
else
    echo -e "\n---- odoo.conf file creation has been failed !!! ----"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

conf_file = "/etc/odoo.conf"

# adding contents to the file
cat <<EOF >"$conf_file"
[options]

; Database operations password:

admin_passwd = odoo

db_host = localhost

db_port = 5432

db_user = odoo

db_password = odoo

addons_path = /opt/odoo/odoo/addons,/opt/odoo/odoo-custom-addons
EOF

echo -e "\n---- config file created successfully"

# creating odoo service
nano 
if  sudo nano /etc/systemd/system/odoo.service ; then
    echo -e "\n---- odoo system service file has been created !!! ----"
else
    echo -e "\n---- odoo system service file creation has been failed !!! ----"
    echo -e "\n---- exiting from script !!! ----"
    exit
fi

service_file = "/etc/systemd/system/odoo.service"



# adding contents to the file
if cat <<EOF >"$conf_file" ; then 

[Unit]

Description=Odoo

Requires=postgresql.service

After=network.target postgresql.service

[Service]

Type=simple

SyslogIdentifier=odoo

PermissionsStartOnly=true

User=odoo

Group=odoo

ExecStart=/opt/odoo/odoo-venv/bin/python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo.conf

StandardOutput=journal+console

[Install]

WantedBy=multi-user.target
EOF

echo -e "\n---- config file created successfully"

else
    echo -e "\n---- service file creation failed in odoo ----"
fi

# updating the service list

echo -e "\n----updating the service list----"

sudo systemctl daemon-reload

# starting odoo 

if sudo systemctl enable --now odoo ; then
    echo -e "\n---- Odoo service has been added in startup----"
else
    echo -e "\n---- odoo service failed in adding in startup----"
fi


