RELEASE ?= monasca-fluentd
FLUENTD_TAG  ?= v1.0-debian
FLUENTD_MONASCA_VERSION ?= 0.1.2
DOCKER_USER ?= stackhpc
IMAGE_REPO ?= ${DOCKER_USER}/${RELEASE}
IMAGE_TAG ?= ${FLUENTD_TAG}-${FLUENTD_MONASCA_VERSION}
NAMESPACE ?= default

.PHONY: all delete build push install logs exec

all: build push install

delete:
	-helm delete ${RELEASE} -n ${NAMESPACE}
build:
	docker build -t ${IMAGE_REPO}:${IMAGE_TAG} --build-arg TAG=${FLUENTD_TAG} --build-arg FLUENTD_MONASCA_VERSION=${FLUENTD_MONASCA_VERSION} .
push:
	docker push ${IMAGE_REPO}:${IMAGE_TAG}
install:
	touch override.yaml
	helm upgrade --install ${RELEASE} chart/ -n ${NAMESPACE} --set fluentd.image.repository=${IMAGE_REPO},fluentd.image.tag=${IMAGE_TAG} -f override.yaml
logs:
	kubectl logs ds/${RELEASE} -n ${NAMESPACE}
exec:
	kubectl exec -it ds/${RELEASE} -n ${NAMESPACE} -- bash
