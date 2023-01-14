debug_elk_go_into_kibana:  # [Debug] Go into the running Kibana container
	@docker exec --interactive --tty ${ELK_KIBANA_CONTATINER_NAME} /bin/bash

debug_elk_go_into_elastic:  # [Debug] Go into the running ElasticSearch container
	@docker exec --interactive --tty ${ELK_ES_CONTATINER_NAME} /bin/bash

debug_elk_go_into_logstash:  # [Debug] Go into the running LogStash container
	@docker exec --interactive --tty ${ELK_LOGSTASH_CONTATINER_NAME} /bin/bash

debug_elk_restart_logstash:
	-@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml restart kbe-log-elk-logstash

debug_elk_run_logstash:
	-@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml run \
		-i \
		--rm \
		 kbe-log-elk-logstash \
		 /bin/bash

debug_print_compose:
	@docker-compose config

debug_print_vars:
	@$(SCRIPTS)/misc/print_configs_vars.sh
