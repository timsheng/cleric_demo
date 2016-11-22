DOCKER_IMAGE_NAME=docker-eu-west-1.dandythrust.com/oslbuild/cleric

build-image:
	docker build -t $(DOCKER_IMAGE_NAME) -f docker/Dockerfile .

upload-image:
	docker push $(DOCKER_IMAGE_NAME)

test-booking-contract-testing:
	mvn test -Denvironment=Stage -DxmlFileName=booking.xml

test-frontendfacade-stage-cn:
	PLATFORM=stage REGION=cn rspec spec/api/frontend_facade_spec.rb

test-frontendfacade-stage-ap:
	PLATFORM=stage REGION=ap rspec spec/api/frontend_facade_spec.rb

test-frontendfacade-stage-eu:
	PLATFORM=stage REGION=eu rspec spec/api/frontend_facade_spec.rb

test-frontendfacade-prod-cn:
	PLATFORM=prod REGION=cn rspec spec/api/frontend_facade_spec.rb


test-frontendfacade-prod-ap:
	PLATFORM=prod REGION=ap rspec spec/api/frontend_facade_spec.rb

test-frontendfacade-prod-eu:
	PLATFORM=prod REGION=eu rspec spec/api/frontend_facade_spec.rb

run-frontendfacade-stage-cn:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-stage-cn"

run-frontendfacade-stage-ap:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-stage-ap"

run-frontendfacade-stage-eu:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-stage-eu"

run-frontendfacade-prod-cn:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-prod-cn"

run-frontendfacade-prod-ap:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-prod-ap"

run-frontendfacade-prod-eu:
	docker run \
		--rm \
		-e CLERIC_ENCRYPT="${CLERIC_ENCRYPT}" \
		-e CLERIC_PRIVATEKEY="${CLERIC_PRIVATEKEY}" \
		${DOCKER_IMAGE_NAME} \
		bash -c "make test-frontendfacade-prod-eu"
