name = inception

all:
	@printf "Iniciando la configuracion de ${name}...\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

build:
	@printf "Construyendo contenedores de ${name}...\n"
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@printf "Deteniendo contenedores de ${name}...\n"
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env down

re: down all

clean: down
	@printf "Limpiando configuracion de ${name}...\n"
	@docker system prune -a
	@sudo rm -rf /home/jaacosta/data/wordpress/*
	@sudo rm -rf /home/jaacosta/data/mariadb/*

fclean: clean
	@printf "Limpieza total de todos los contenedores de docker\n"
	@docker stop $$(docker ps -qa) 2>/dev/null || true
	@docker rm $$(docker ps -qa) 2>/dev/null || true
	@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker network rm $$(docker network ls -q) 2>/dev/null || true

.PHONY: all build down re clean fclean
