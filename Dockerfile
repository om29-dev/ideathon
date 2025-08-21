# Frontend Dockerfile
FROM node:18-alpine as frontend-build

WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci --only=production

COPY frontend/ ./
RUN npm run build

# Backend Dockerfile
FROM python:3.9-slim as backend

WORKDIR /app
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ ./

# Final stage - Nginx to serve frontend and proxy to backend
FROM nginx:alpine

# Copy frontend build
COPY --from=frontend-build /app/dist /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy backend
COPY --from=backend /app /backend
RUN apk add --no-cache python3 py3-pip
RUN pip3 install --no-cache-dir -r /backend/requirements.txt

EXPOSE 80
EXPOSE 8000

# Start both frontend and backend
COPY start-container.sh /start-container.sh
RUN chmod +x /start-container.sh

CMD ["/start-container.sh"]
