FROM golang:1.24.5 AS builder

WORKDIR /next-task-svc

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main .

FROM debian:bookworm-slim

WORKDIR /next-task-svc

COPY --from=builder /next-task-svc/main .

EXPOSE ${SERVER_PORT}

# Run the app
ENTRYPOINT ["./main"]
