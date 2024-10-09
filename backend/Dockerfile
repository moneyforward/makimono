FROM golang:1.23.2-alpine3.20 AS builder

WORKDIR /build

COPY go.mod ./
RUN go mod download

COPY . .
RUN go build -o /app .

FROM alpine:3.20

COPY --from=builder /app /app
CMD ["/app"]
