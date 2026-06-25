@echo off
echo Subindo Biblioteca API...
docker compose up -d --build
if errorlevel 1 exit /b %errorlevel%
echo.
echo Aguardando servicos...
timeout /t 5 /nobreak >nul
docker compose ps
echo.
echo API disponivel em: http://localhost:8080
echo Swagger:           http://localhost:8080/api-docs
echo Health:            http://localhost:8080/health
