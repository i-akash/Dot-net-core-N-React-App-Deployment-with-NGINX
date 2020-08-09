
#                                   Copying and making required dir

# directory 
DEST_DIR="/var/www/cefalo-all-apps"
SRC_DIR="/home/sysadmin/cefalo-all-apps"

# make destination dir
sudo mkdir $DEST_DIR 
sudo chmod -R  777 $DEST_DIR

# copy to directory pointed by nginx
sudo cp -r "$SRC_DIR/." "$DEST_DIR/"
# remove directory
sudo rm -r $SRC_DIR

# make necessary folder in api
cd "$DEST_DIR/cefalo-hrportal-api"
mkdir -p App_Data/TemporaryUploads
sudo chmod -R  777 App_Data/TemporaryUploads
mkdir -p Media/avatars
sudo chmod -R  777 Media/avatars



#                         Service and Configuration Initialization Part

API_SERVICE="[Unit]
Description=CEFALO HR PORTAL API

[Service]
WorkingDirectory=/var/www/cefalo-all-apps/cefalo-hrportal-api
ExecStart=/usr/bin/dotnet /var/www/cefalo-all-apps/cefalo-hrportal-api/Cefalo.AttendanceManagement.Api.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=CEFALO-HR-PORTAL
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target"

SYNC_SERVICE="[Unit]
Description=CEFALO HR PORTAL SYNC SERVICE

[Service]
Type=notify
WorkingDirectory=/var/www/cefalo-all-apps/cefalo-hrportal-sync-service/
ExecStart=/usr/bin/dotnet /var/www/cefalo-all-apps/cefalo-hrportal-sync-service/Cefalo.AttendanceSyncService.dll
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target"

NGINX_CONG="server {
    listen              5001 default_server;
    server_name         www.hrportal.cefalolab.com;

    location /api {
        proxy_pass         http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }

    location / {
        root /var/www/cefalo-all-apps/cefalo-hrportal-ui;
        index index.html index.htm;
        location / {
             try_files \$uri /index.html;
        }
    }
}"

# write 3 files with contents
sudo echo "$NGINX_CONG" > /etc/nginx/sites-available/default
sudo echo "$API_SERVICE" > /etc/systemd/system/cefalo-hrportal-api.service
sudo echo "$SYNC_SERVICE" > /etc/systemd/system/cefalo-hrportal-sync-service.service


#                               configure appsettings

API_APP_SETTINGS='
{
  "ConnectionStrings": {
    "AttendanceManagementContext": "Data Source=localhost;Database=CefaloHrPortal;User ID=sa;Password=cefal0+VI",
    "AttendanceSourceContext": "Data Source=localhost;Database=Biostar;User ID=sa;Password=cefal0+VI"
  },
  "StaticFolderPath": "Media/avatars",
  "Serilog": {
    "MinimumLevel": {
      "Default": "Debug",
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Async",
        "Args": {
          "configure": [
            {
              "Name": "File",
              "Args": {
                "path": "/var/www/cefalo-all-apps/logs/attendance-managment-api.json",
                "formatter": "Serilog.Formatting.Json.JsonFormatter, Serilog",
                "rollingInterval": "Day",
                "retainedFileCountLimit": 7
              }
            }
          ]
        }
      }
    ]
  },
  "AllowedHosts": "*",
  "KnownProxy": "192.168.1.58",
  "AttendanceManagement": {
    "MigrateDatabaseOnStartup": true,
    "AuthenticationConfiguration": {
      "Secret": "s9hAq<O9&PwiQNauqNASh;1ash|uewp%5klzln!&#%!sdhA,Hsa@1dvgs%^%!$@%vgahscfga"
    },
    "EmailConfiguration": {
      "SmtpServer": "smtp.gmail.com",
      "Port": 587,
      "Username": "notification@cefalo.com",
      "Password": "cefaloBD",
      "Timeout": 3600000,
      "ApplicationResponderName": "Sajjadul Islam Shanto",
      "SendEmail": true
    }
  },
  "ClientConfiguration": {
    "HasWildCard": true,
    "Hosts": [ "https://hrportal.cefalolab.com", "http://192.168.1.58:5001" ],
    "ExposedHeaders": [ "X-Pagination", "content-disposition", "X-AttachmentName" ]
  }
}'
SYNC_APP_SETTINGS='
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "ConnectionStrings": {
    "AttendanceManagementContext": "Data Source=localhost;Database=CefaloHrPortal;User ID=sa;Password=cefal0+VI",
    "AttendanceSourceContext": "Data Source=localhost;Database=Biostar;User ID=sa;Password=cefal0+VI"
  },
  "AttendanceSyncServiceSettings": {
    "ServiceStartTime": "06:00",
    "ServiceEndTime": "23:59",
    "ServiceIntrvalInMinute": 1,
    "PreviousDaysToReloadMissingData": 7
  },
  "Serilog": {
    "Using": [ "Serilog.Sinks.File" ],
    "MinimumLevel": {
      "Default": "Debug",
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Async",
        "Args": {
          "configure": [
            {
              "Name": "File",
              "Args": {
                "path": "/var/www/cefalo-all-apps/logs/attendance-sync-service.json",
                "formatter": "Serilog.Formatting.Json.JsonFormatter, Serilog",
                "rollingInterval": "Day",
                "retainedFileCountLimit": 10,
                "fileSizeLimitBytes": 102400,
                "rollOnFileSizeLimit": true
              }
            }
          ]
        }
      }
    ]
  }
}'

sudo echo "$API_APP_SETTINGS" > "$DEST_DIR/cefalo-hrportal-api/appsettings.json"
sudo echo "$SYNC_APP_SETTINGS" > "$DEST_DIR/cefalo-hrportal-sync-service/appsettings.json"

#                                Service Starting and Status

# reload all service, restart and show status 
sudo systemctl daemon-reload 
sudo systemctl restart cefalo-hrportal-api.service cefalo-hrportal-sync-service.service nginx.service mssql-server.service
sudo systemctl status cefalo-hrportal-api.service cefalo-hrportal-sync-service.service nginx.service mssql-server.service 

#                                Firewall configuration
# firewall 
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow "Nginx Full"
sudo ufw allow "Nginx HTTP"
sudo ufw allow "Nginx HTTPS"