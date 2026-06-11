# Stage 1: Build React frontend
FROM node:18-alpine AS builder
WORKDIR /app
COPY mynotes/package*.json ./
RUN npm install
COPY mynotes/ ./
RUN npm run build

# Stage 2: Serve React frontend with Nginx
FROM nginx:1.23.3-alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf