WIDTH := 20
HEIGHT := 20
DELAY := 0.2

SNAKEFILE 	:= $(lastword $(MAKEFILE_LIST))
COMMA		:= ,

SNAKE_DIR		:= .snake_state
SNAKE_FILE		:= $(SNAKE_DIR)/.snake
FOOD_FILE		:= $(SNAKE_DIR)/.food
STATE_FILE		:= $(SNAKE_DIR)/.state
STTY_SAVE_FILE	:= $(SNAKE_DIR)/.stty_save

.PHONY: run init gen_food loop read_input move draw clean

run: init clean
	@# Exit

init:
	@mkdir $(SNAKE_DIR) 2>/dev/null || true
	@stty -g > $(STTY_SAVE_FILE) 2>/dev/null
	@echo "2,0 1,0 0,0" > $(SNAKE_FILE)
	@echo "1 0" > $(STATE_FILE)
	@echo "4,0" > $(FOOD_FILE)
	@$(MAKE) -f $(SNAKEFILE) draw
	@$(MAKE) -s -f $(SNAKEFILE) loop; \
	stty $(cat $(STTY_SAVE_FILE)) 2>/dev/null; \
	SCORE=$$(cat $(SNAKE_FILE) | wc -w); \
	case "$$(cat $(STATE_FILE))" in \
		gameover) MSG="Game Over! Score: $$SCORE" ;; \
		quit)     MSG="Goodbye! Score: $$SCORE" ;; \
		*) exit 1 ;; \
	esac; \
	tput clear; \
	printf "%$${#MSG}s\n" | tr ' ' '='; \
	echo "$$MSG"; \
	printf "%$${#MSG}s\n" | tr ' ' '=';

gen_food:
	while true; do \
		food_x=$$(awk 'BEGIN{srand(); print int(rand()*$(WIDTH))}'); \
		food_y=$$(awk 'BEGIN{srand(); print int(rand()*$(HEIGHT))}'); \
		is_snake=0; \
		for point in $$(cat $(SNAKE_FILE)); do \
			[ "$$food_x,$$food_y" = "$$point" ] && is_snake=1; \
		done; \
		[ $$is_snake -eq 0 ] && break; \
	done; \
	echo "$$food_x,$$food_y" > $(FOOD_FILE)

loop: read_input move draw
	@sleep $(DELAY)
	@$(MAKE) -f $(SNAKEFILE) loop

read_input:
	stty -icanon time 0 min 0 2>/dev/null || true; \
	key=$$(dd bs=1 count=1 2>/dev/null); \
	if [ "$$key" = "$$(printf '\033')" ]; then \
		stty -icanon min 1 time 0 2>/dev/null; \
		dir=$$(dd bs=1 count=2 2>/dev/null); \
		case "$$dir" in \
			'[A') key="w" ;; \
			'[B') key="s" ;; \
			'[C') key="d" ;; \
			'[D') key="a" ;; \
		esac; \
	fi; \
	case "$$key" in \
		'w') echo "0 -1" > $(STATE_FILE) ;; \
		's') echo "0 1"  > $(STATE_FILE) ;; \
		'd') echo "1 0"  > $(STATE_FILE) ;; \
		'a') echo "-1 0" > $(STATE_FILE) ;; \
		'q') echo "quit" > $(STATE_FILE); exit 1 ;; \
	esac

move:
	@# Information gathering
	@$(eval DIR := $(shell cat $(STATE_FILE)))
	@$(eval DX := $(word 1,$(DIR)))
	@$(eval DY := $(word 2,$(DIR)))
	@#
	@$(eval SNAKE := $(shell cat $(SNAKE_FILE)))
	@$(eval HEAD := $(subst $(COMMA), ,$(word 1,$(SNAKE))))
	@$(eval HEAD_X := $(word 1,$(HEAD)))
	@$(eval HEAD_Y := $(word 2,$(HEAD)))
	@#
	@$(eval NEW_X := $(shell echo $$(($(HEAD_X) + $(DX)))))
	@$(eval NEW_Y := $(shell echo $$(($(HEAD_Y) + $(DY)))))
	@#
	@# Collision with a wall
	@if [ $(NEW_X) -lt 0 ] || [ $(NEW_X) -ge $(WIDTH) ] || [ $(NEW_Y) -lt 0 ] || [ $(NEW_Y) -ge $(HEIGHT) ]; then \
		echo "gameover" > $(STATE_FILE); \
		exit 1; \
	fi
	@#
	@# Self-collision
	@snake_str="$(SNAKE)"; \
	set -- $$snake_str; \
	head="$$1"; shift; \
	for part; do \
		if [ "$$part" = "$$head" ]; then \
			echo "gameover" > "$(STATE_FILE)"; \
			exit 1; \
		fi; \
	done
	@#
	@# New snake
	@$(eval FOOD := $(shell cat $(FOOD_FILE)))
	@if [ "$(NEW_X),$(NEW_Y)" = "$(FOOD)" ]; then \
		NEW_SNAKE="$(NEW_X),$(NEW_Y) $(SNAKE)"; \
		$(MAKE) -f $(SNAKEFILE) gen_food; \
	else \
		NEW_SNAKE="$(NEW_X),$(NEW_Y) $(wordlist 1,$(shell expr $(words $(SNAKE)) - 1), $(SNAKE))"; \
	fi; \
	echo $$NEW_SNAKE > $(SNAKE_FILE)

draw:
	@tput clear
	@$(eval SNAKE := $(shell cat $(SNAKE_FILE)))
	@$(eval FOOD := $(shell cat $(FOOD_FILE)))
	@printf "+%${WIDTH}s+\n" | tr ' ' '-'
	@y=0; while [ $$y -lt $(HEIGHT) ]; do \
		printf "|"; \
		x=0; while [ $$x -lt $(WIDTH) ]; do \
			is_snake=0; \
			for point in $(SNAKE); do \
				[ "$$x,$$y" = "$$point" ] &&	is_snake=1; \
			done; \
			if [ $$is_snake -eq 1 ]; then \
				printf "O"; \
			elif [ "$$x,$$y" = "$(FOOD)" ]; then \
				printf "\$$"; \
			else \
				printf " "; \
			fi; \
			x=$$(( x + 1 )); \
		done; \
		echo "|"; \
		y=$$(( y + 1 )); \
	done
	@printf "+%${WIDTH}s+\n" | tr ' ' '-'
	@echo "Score: $$(cat $(SNAKE_FILE) | wc -w)"

clean:
	@rm -rf $(SNAKE_DIR)
