all:
	docker build --pull -t robhammond/pgbouncer-k8s .

clean:
	docker rmi robhammond/pgbouncer-k8s:latest