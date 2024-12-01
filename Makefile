PROJECT_PKG = github.com/butler54/aoc-24
BUILD_DIR = build
VERSION ?=$(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
# remove debug info from the binary & make it smaller
LDFLAGS += -s -w
# inject build info
LDFLAGS += -X ${PROJECT_PKG}/internal/app/build.Version=${VERSION} -X ${PROJECT_PKG}/internal/app/build.CommitHash=${COMMIT_HASH} -X ${PROJECT_PKG}/internal/app/build.BuildDate=${BUILD_DATE}



.PHONY: build
build:
	go build ${GOARGS} -tags "${GOTAGS}" -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/aoc ./cmd/aoc

gen:
	go generate ./...

deps:
	wire ./...

swagger:
	swag init --parseDependency -g cmd/app/main.go --output=./api

proto:
	protoc --go_out=plugins=grpc:. internal/grpc/schema/*.proto

install-tools:
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.33.0
	go get github.com/google/wire/cmd/wire
	go get -u github.com/onsi/ginkgo/ginkgo
	go get -u github.com/swaggo/swag/cmd/swag
