CMD?=
TARGET?=dev
DOCKER_IMAGE?=unicef/odk
DOCKERFILE?=Dockerfile
BUILD_OPTIONS?=--squash
RUN_OPTIONS?=
DEVELOP?="0"
PREFIX=`basename ${PWD}`


ODK_HOSTNAME?=
ODK_ADMIN_USER?=
ODK_ADMIN_USERNAME?=admin
ODK_AUTH_REALM?=ODK Aggregate
ODK_PORT?=8080
ODK_PORT_SECURE?=8443
DATABASE_URL?=jdbc:postgresql://db:5432/odk
POSTGRES_USER=?postgres
POSTGRES_PASSWORD=password

FLYWAY?=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.0.3/flyway-commandline-4.0.3-linux-x64.tar.gz
ODK?=https://github.com/opendatakit/aggregate/releases/download/v1.6.1/ODK-Aggregate-v1.6.1-Linux-x64.run





help:
	@echo 'Usage:                                                         '
	@echo '   make clean            removes images and containers         '
	@echo '   make build            build the image                       '
	@echo '   make run              run the container                     '
	@echo '   make push             push image to docker hub              '
	@echo '   make fullclean        cleanup development environment       '
	@echo '                                                               '


clean:
	rm -fr ~build


fullclean: clean
	-@docker rmi ${DOCKER_IMAGE}:${TARGET}
	-@docker rm ${PREFIX}_db_1 ${PREFIX}_adminer_1 ${PREFIX}_odk_1
	rm -fr cache .venv


build: clean cache
	docker build ${BUILD_OPTIONS} \
		--build-arg DEVELOP=${DEVELOP} \
		--build-arg VERSION=${TARGET} \
		-t ${DOCKER_IMAGE}:${TARGET} \
		-f ${DOCKERFILE} .
	docker images | grep ${DOCKER_IMAGE}

.run:
	docker run \
		--rm \
		-p 8080:8080 \
		${RUN_OPTIONS} \
		-e ODK_HOSTNAME="${ODK_HOSTNAME}" \
		-e ODK_ADMIN_USERNAME="${ODK_ADMIN_USERNAME}" \
		-e ODK_AUTH_REALM="${ODK_AUTH_REALM}" \
		-e POSTGRES_USER="${POSTGRES_USER}" \
		-e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
		-e DATABASE_URL="${DATABASE_URL}" \
		-e CONFIGURE=0 \
		-it ${DOCKER_IMAGE}:${TARGET} \
		${CMD}

cache:
	if [ ! -f cache/flyway.tar.gz ]; then curl -L ${FLYWAY} -o cache/flyway.tar.gz; fi
	if [ ! -f cache/odk.run ]; then curl -L ${ODK} -o cache/odk.run; fi

run:
	CMD='odk' $(MAKE) .run

debug:
	CMD='/bin/bash' \
		RUN_OPTIONS="-v ${PWD}/~build/workdir:/workdir -v ${PWD}/~build/var:/var/odk -v ${PWD}/~build/root:/root" \
		$(MAKE) .run

shell:
	CMD='/bin/bash' $(MAKE) .run

push:
	docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
	docker tag ${DOCKER_IMAGE}:${TARGET} ${DOCKER_IMAGE}:latest
	docker push ${DOCKER_IMAGE}:${TARGET}
	docker push ${DOCKER_IMAGE}:latest


.PHONY: run
