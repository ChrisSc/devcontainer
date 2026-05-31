# Shortcuts for the Claude sandbox. Compose lives in .devcontainer/.
COMPOSE := docker compose -f .devcontainer/compose.yaml

.PHONY: up shell rebuild logs stop down nuke firewall doctor cp-skill

up:        ## Build (if needed) and start the container
	$(COMPOSE) up -d --build

shell:     ## Interactive login shell as `claude`
	docker exec -it claude-code zsh -l

rebuild:   ## Rebuild the image from scratch and restart
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d

logs:      ## Follow container logs (firewall + startup output)
	$(COMPOSE) logs -f

stop:      ## Stop the container (volumes + data preserved)
	$(COMPOSE) stop

down:      ## Remove the container (named volumes preserved)
	$(COMPOSE) down

nuke:      ## Remove the container AND all named volumes (destroys data)
	$(COMPOSE) down -v

firewall:  ## Re-apply the egress firewall (e.g. after editing extra-allowlist.txt)
	docker exec claude-code sudo /usr/local/bin/init-firewall.sh

doctor:    ## Run claude doctor inside the container
	docker exec -it claude-code claude doctor

cp-skill:  ## Copy a skill folder into ~/.claude/skills owned by claude: make cp-skill SRC=~/dev/my-skill
	@test -n "$(SRC)" || { echo "usage: make cp-skill SRC=<path-to-skill-folder>"; exit 1; }
	@test -d "$(SRC)" || { echo "error: $(SRC) is not a directory"; exit 1; }
	tar -C "$(dir $(SRC:/=))" -cf - "$(notdir $(SRC:/=))" | \
	  docker exec -i -u claude claude-code tar -C /home/claude/.claude/skills -xf -
	@echo "copied $(notdir $(SRC:/=)) -> ~/.claude/skills (owned by claude)"
