debezium-%: #create || update
	docker compose exec debezium bash /debezium/connector.sh $*
