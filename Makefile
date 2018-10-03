CMD?=
TARGET?=dev
PIPENV_PYPI_MIRROR?=https://pypi.org/simple/
DOCKER_IMAGE?=unicef/odk
DOCKERFILE?=Dockerfile
BUILD_OPTIONS?=--squash
DEVELOP?="0"
FLYWAY?=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.0.3/flyway-commandline-4.0.3-linux-x64.tar.gz
ODK?=https://github.com/opendatakit/aggregate/releases/download/v1.6.1/ODK-Aggregate-v1.6.1-Linux-x64.run


help:
	@echo 'Usage:                                                         '
	@echo '   make clean            removes images and containers         '
	@echo '   make build            build container                       '
	@echo '   make push             push image to docker hub              '
	@echo '                                                               '


clean:
	-docker rmi ${DOCKER_IMAGE}:${TARGET}
	rm -fr ~build


build: clean
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
		-e ODK_HOSTNAME="${ODK_HOSTNAME}" \
		-e ODK_ADMIN_USERNAME="${ODK_ADMIN_USERNAME}" \
		-e ODK_AUTH_REALM="${ODK_AUTH_REALM}" \
		-e POSTGRES_USER="${POSTGRES_USER}" \
		-e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
		-e DATABASE_URL="${DATABASE_URL}" \
		-e CONFIGURE=0 \
		-v ${PWD}/~build/workdir:/workdir \
		-v ${PWD}/~build/var:/var/odk \
		-v ${PWD}/~build/root:/root \
		-it ${DOCKER_IMAGE}:${TARGET} \
		${CMD}

cache:
	mkdir -p .cache
	if [ ! -f .cache/flyway.tar.gz ]; then curl -L ${FLYWAY} -o .cache/flyway.tar.gz; fi
	if [ ! -f .cache/odk.run ]; then curl -L ${ODK} -o .cache/odk.run; fi

run:
	CMD='odk' $(MAKE) .run


shell:
	CMD='/bin/bash' $(MAKE) .run

push:
	docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
	docker tag ${DOCKER_IMAGE}:${TARGET} ${DOCKER_IMAGE}:latest
	docker push ${DOCKER_IMAGE}:${TARGET}
	docker push ${DOCKER_IMAGE}:latest


.PHONY: run
