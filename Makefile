DOCKER_IMAGE_NAME=docker-cn-north-1.dandythrust.com/oslbuild/cleric

build-image:
	docker build -t $(DOCKER_IMAGE_NAME) -f docker/Dockerfile .

upload-image:
	docker push $(DOCKER_IMAGE_NAME)

test-booking-contract-testing:
	mvn test -Denvironment=Stage -DxmlFileName=booking.xml

test-frontendfacade-contract-testing:
	mvn test -Denvironment=Stage -DxmlFileName=frontend_facade.xml

run-test-container-booking:
	docker run \
		-it --rm \
		-e KEY_ENV="${KEY_ENV}" \
		-e STORMAPI_PRIVATEKEY="${STORMAPI_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash

run-test-container-frontendfacade:
	docker run \
		-it --rm \
		-e KEY_ENV="${KEY_ENV}" \
        	-e STORMAPI_PRIVATEKEY="${STORMAPI_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-contract-testing"
