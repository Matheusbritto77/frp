# Stage 1: Build Web Dashboard Frontend
FROM node:22-alpine AS web-builder

WORKDIR /web
COPY web/package*.json ./
COPY web/shared/ ./shared/
COPY web/frps/ ./frps/
RUN npm ci --legacy-peer-deps || npm install --legacy-peer-deps
WORKDIR /web/frps
RUN npm run build

# Stage 2: Build Go Server Binary
FROM golang:alpine AS builder

ENV GOTOOLCHAIN=auto

WORKDIR /src
COPY . .
COPY --from=web-builder /web/frps/dist /src/web/frps/dist

RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -tags frps -o /frps ./cmd/frps

# Stage 3: Minimal Runtime Container
FROM alpine:latest
RUN apk add --no-cache tzdata ca-certificates
COPY --from=builder /frps /usr/bin/frps
COPY frps.toml /etc/frp/frps.toml

ENTRYPOINT ["/usr/bin/frps", "-c", "/etc/frp/frps.toml"]
