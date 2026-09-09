# Инструкция по работе с DockerAutomation


Первоначальная нстройка

    1. Установить [DockerDesktop] (https://www.docker.com/products/docker-desktop/)
    2. Перенести файлы (docker-compose.yml, vite.config.js, vite.config.ts) из папки "Для замены" в проект. 
    3. Указать настройки подключения к базе данных в docker-compose.yml

Build (Первый процес сборки может быть очень долгим!)

    1. Указать путь к проекту в файле "build.ps1"
    2. Указать путь к файлу "build.ps1" в файле  "build.bat"
    3. Запустить "build.bat"


Export

    1. Указать путь к проекту в файле "export.ps1"
    2. Указать путь для экспорта в "*/LoadAndRun/Windows/eye_of_reservoir.tar"
    3. Указать путь к файлу "export.ps1" в файле "export.bat"
    4. Запустить "export.bat"

Load

    1.Убедиться, что в папке "LoadAndRun/Windows" есть файлы (infa/nginx/nginx.conf, .env, docker-compose.yml, eye_of_reservoir.tar)
    2. Указать настройки подключения к бд в файлых (.env и docker-compose.yml)
    3. Указать путь к папке "LoadAndRun/Windows" в файле "load.ps1"
    4. Указать путь к файлу "load.ps1" в файле load.bat
    5. Запустить "load.bat"

Run

    1.Убедиться, что в папке "LoadAndRun/Windows" есть файлы (infa/nginx/nginx.conf, .env, docker-compose.yml, eye_of_reservoir.tar)    
    2. Указать настройки подключения к бд в файлых (.env и docker-compose.yml)
    3. Указать путь к папке "LoadAndRun/Windows" в файле "run.ps1"
    4. Указать путь к файлу "run.ps1" в файле run.bat
    5. Запустить "run.bat"

