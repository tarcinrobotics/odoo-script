################################################################################
# Organization : Tarcin Robotic LLP
# Author       : vigneshpandian
################################################################################
#!/bin/bash
# declaration of variables for location storage
conf_file = "/etc/odoo.conf"
service_file = "/etc/systemd/system/odoo.service"

# updating server 
echo -e "\n---- Updating Server ----\n"

#sudo apt update

#sudo apt upgrade -y

# creating and giving permission directories

# creating dir
if sudo mkdir -p /opt/odoo16/odoo ; then
    echo "\n---- odoo directory has been created ----\n"
else
    echo "\n---- Failed to create the odoo directory !!! ----\n"
fi
# giving permission to dir
if sudo chmod u+w /opt/odoo16 ; then
    echo "\n---- successfully given permission to odoo directory ----\n"
else
    echo "\n---- Failed to create the odoo directory !!! ----\n"
fi
# giving permission to odoo user
if sudo chown -R odoo /opt/odoo16 ; then
    echo "\n---- giving permission to odoo user ----\n"
else
    echo "\n---- Failed to give permission to odoo user ----\n"
fi
# installing pre-requisites packages 
echo -e "\n---- Installing Pre-requisites ----\n"
sudo apt install -y build-essential wget python3-dev python3-venv python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev postgresql
echo -e "\n---- completed installing pre-requisites !!! ----\n"

# creating odoo user

echo -e "\n---- Creating Odoo user ----\n"

if sudo useradd -m -d /opt/odoo -U -r -s /bin/bash odoo ; then
    echo -e "\n---- completed creating odoo user  !!! ----\n"
else
    echo "odoo user creation failed / the user already exists"
fi

# creating postgres sql user for odoo

echo -e "\n---- Creating Postgresql user for user ----\n"

if sudo su - postgres -c 'createuser -s odoo'; then
    echo -e "\n---- completed creating postgresql user !!! ----\n"
else
    echo -e "postgersql user creation failed !!!"
fi

# installation of wkhtmltopdf    

# downloading wkhtmltopdf

echo -e "\n---- Installation of wkhtmltopdf ----\n"
echo -e "\n\n---- Downloading wkhtmltopdf ----\n"

# installing wkhtmltopdf

#echo -e "\n---- installing wkhtmltopdf ----\n"

if sudo apt install wkhtmltopdf -y ; then
    echo -e "\n---- completed installing wkhtmltopdf !!! ----\n"
else
    echo -e "\n---- failed installing wkhtmltopdf !!! ----\n"
fi

# installation and configuration of odoo

echo -e "\n---- Switching to odoo user ----\n"
sudo su - odoo  <<EOF


echo -e "\n---- cloning from github ----\n"


if git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 /opt/odoo16/odoo ; then 
    echo -e "\n---- successfully cloned from github !!! ----\n"
else
    echo -e "\n---- failed cloning from github !!! ----\n"
    echo -e "\n---- exiting from script !!! ----\n"
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
    echo -e "\n---- exiting from script !!! ----\n"
    exit
fi

# installing requirements for odoo
pip3 install wheel

# installing odoo-requirements.txt file
if source pip3 install -r /opt/odoo16/odoo/requirements.txt ; then
    echo "\n---- requirements installed successfully !!!"
else
    echo "\n---- requirements installation failed !!!"
    echo -e "\n---- exiting from script !!! ----\n"
    exit
fi

# deactivating the environment

if deactivate ; then
    echo -e "\n---- virtual environment deactivated and proceeding to next.... ----\n"
else
    echo -e "\n---- virtual environment not deactivated !!! ----\n"
fi

# creating custom-addons

echo -e "\n---- creating custom-addons directory----\n"
if mkdir /opt/odoo/odoo-custom-addons ; then
    echo -e "\n---- custom-addons directory has been created successfully !!! ----\n"
else
    echo -e "\n---- directory creation failed !!!"
    echo -e "\n---- exiting from script !!! ----\n"
    exit
fi

# exiting from odoo user

echo -e "\n---- exiting from odoo user ----\n"

if exit ; then
    echo -e "\n---- exited from odoo user !!! ----\n"
else
    echo -e "\n---- exiting from odoo user failed !!! ----\n"
    exit
fi
EOF
# creating odoo.conf file 

if sudo touch /etc/odoo.conf ; then
    echo -e "\n---- new odoo.conf file has been created !!! ----\n"
else
    echo -e "\n---- odoo.conf file creation has been failed !!! ----\n"
    echo -e "\n---- exiting from script !!! ----\n"
    exit
fi


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

echo -e "\n---- config file created successfully ----\n"

# creating odoo service

if  sudo touch /etc/systemd/system/odoo.service ; then
    echo -e "\n---- odoo system service file has been created !!! ----\n"
else
    echo -e "\n---- odoo system service file creation has been failed !!! ----\n"
    echo -e "\n---- exiting from script !!! ----\n"
    exit
fi





# adding contents to the file
cat <<EOF >"$service_file"  

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

# updating the service list

echo -e "\n----updating the service list----\n"

sudo systemctl daemon-reload

# starting odoo 

if sudo systemctl enable --now odoo ; then
    echo -e "\n---- Odoo service has been added in startup----\n"
else
    echo -e "\n---- odoo service failed in adding in startup----\n"
fi


