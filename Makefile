DOCKER_IMAGE_NAME=docker-cn-north-1.dandythrust.com/oslbuild/cleric

build-image:
	docker build -t $(DOCKER_IMAGE_NAME) -f docker/Dockerfile .

upload-image:
	docker push $(DOCKER_IMAGE_NAME)

test-booking-contract-testing:
	mvn test -Denvironment=Stage -DxmlFileName=booking.xml

test-frontendfacade-contract-testing:
	PLATFORM=stage rspec spec/api/frontend_facade_spec.rb

run-test-container-booking:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash

run-test-container-frontendfacade:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-contract-testing"
