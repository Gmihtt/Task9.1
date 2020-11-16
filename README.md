# Команды make
* make build - создает докер образ gmihtt/multi-layer на основе проекта (P.S. установка зависимостей происходит действительно долго)
* make buildApp - строит приложение на основе 3 образов mongo gmihtt/server и redis
* make start - запускает сервер в автономном режиме, прослушывающий localhost:8080
* make healthcheck - проверяет установлен ли docker
