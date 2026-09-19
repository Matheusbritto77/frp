FROM golang:1.24-alpine AS builder

WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -ldflags "-s -w" -o /frps ./cmd/frps

FROM alpine:latest
RUN apk add --no-cache tzdata ca-certificates
COPY --from=builder /frps /usr/bin/frps
COPY frps.toml /etc/frp/frps.toml

ENTRYPOINT ["/usr/bin/frps", "-c", "/etc/frp/frps.toml"]
