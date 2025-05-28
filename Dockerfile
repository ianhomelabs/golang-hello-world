# Stage 1: Build
FROM golang:1.24-alpine AS builder

# Install git (untuk go mod jika perlu mengambil dari repo), dan timezone (opsional)
RUN apk add --no-cache git tzdata

WORKDIR /app

# Copy go mod files lebih awal untuk memanfaatkan layer cache
COPY go.mod go.sum ./
RUN go mod download

# Copy seluruh project dan build
COPY . .

# Build dengan opsi optimasi ukuran binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o main .

# Stage 2: Minimal runtime image
FROM alpine:latest

# Install timezone data (jika dibutuhkan)
RUN apk add --no-cache tzdata

WORKDIR /app

# Copy binary dari builder
COPY --from=builder /app/main .

# Set timezone ke Asia/Jakarta jika dibutuhkan (opsional)
# ENV TZ=Asia/Jakarta

EXPOSE 8080

# Jalankan aplikasi
CMD ["./main"]