# Refresh all services
sudo systemctl daemon-reload
# restart 
sudo systemctl restart cefalo-hrportal-api.service cefalo-hrportal-sync-service.service nginx.service mssql-server.service
# status
sudo systemctl status cefalo-hrportal-api.service cefalo-hrportal-sync-service.service  nginx.service mssql-server.service 
