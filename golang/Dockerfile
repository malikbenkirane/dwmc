FROM golang:1.27-bookworm AS gopls-builder
RUN go install golang.org/x/tools/gopls@latest

FROM golang:1.27-bookworm AS golangci-lint-builder
RUN go install github.com/nametake/golangci-lint-langserver@latest
RUN curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.13.1

FROM golang:1.27-bookworm AS dlv-builder
RUN go install github.com/go-delve/delve/cmd/dlv@latest

FROM dwmc:core
USER root
COPY --from=gopls-builder /go/bin/gopls /usr/local/bin/gopls
COPY --from=golangci-lint-builder /go/bin/golangci-lint-langserver /usr/local/bin/golangci-lint-langserver
COPY --from=golangci-lint-builder /go/bin/golangci-lint /usr/local/bin/golangci-lint
COPY --from=dlv-builder /go/bin/dlv /usr/local/bin/dlv
USER agent
