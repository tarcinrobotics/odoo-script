################################################################################
# Organization : Tarcin Robotic LLP
# Author       : vigneshpandian
################################################################################
#!/bin/bash

conf_file="/etc/odoo.conf"
service_file="/etc/systemd/system/odoo.service"

config_content="
[options]

; Database operations password:

admin_passwd = odoo

db_host = localhost

db_port = 5432

db_user = odoo

db_password = odoo

addons_path = /opt/odoo/odoo/addons,/opt/odoo/odoo-custom-addons"

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

ExecStart=/opt/odoo/odoo-venv/bin/python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo.conf

StandardOutput=journal+console

[Install]

WantedBy=multi-user.target"

# creating odoo.conf file 

#if sudo touch /etc/odoo.conf ; then
#    echo -e "\n---- new odoo.conf file has been created !!! ----\n"
#else
#    echo -e "\n---- odoo.conf file creation has been failed / file already exists !!! ----\n"   
#fi


# adding contents to the file
if  echo "$config_content" > "$config_file" ; then
    echo -e "\n---- config file created successfully ----\n"
else
    echo -e "\n---- failed to create odoo.conf file ----\n"
fi

# creating odoo service
#if  sudo touch /etc/systemd/system/odoo.service ; then
#    echo -e "\n---- odoo system service file has been created !!! ----\n"
#else
#    echo -e "\n---- odoo system service file creation has been failed / file already exists!!! ----\n"
#fi


# adding contents to the file

if echo "$service_content" > "$service_file"  ; then
        echo -e "\n---- service file created successfully ----\n"
else
        echo -e "\n---- failed to create service file ----\n"
fi
# updating the service list

echo -e "\n----updating the service list----\n"

sudo systemctl daemon-reload

# starting odoo 

if sudo systemctl enable --now odoo ; then
    echo -e "\n---- Odoo service has been added in startup----\n"
else
    echo -e "\n---- odoo service failed in adding in startup----\n"
fi
