.PHONY: start load hive local yarn status stop clean all

start:
	bash scripts/start_stack.sh

load:
	docker compose exec client bash /workspace/scripts/load_github_events_to_hdfs.sh

hive:
	bash scripts/run_hive_setup.sh

local:
	bash scripts/run_local.sh

yarn:
	bash scripts/run_yarn.sh

status:
	bash scripts/status.sh

stop:
	bash scripts/stop_stack.sh

clean:
	bash scripts/clean_stack.sh

all:
	bash scripts/run_all.sh
