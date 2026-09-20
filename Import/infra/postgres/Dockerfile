FROM postgres:18

COPY init/dump.sql      /docker-entrypoint-initdb.d/dump.sql
COPY init/01-restore.sh /docker-entrypoint-initdb.d/01-restore.sh

# На всякий случай убираем CRLF, если файлы могли прийти из Windows
RUN sed -i 's/\r$//' /docker-entrypoint-initdb.d/01-restore.sh

# chmod +x НЕ делаем: entrypoint выполнит скрипт через source