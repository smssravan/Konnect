# Use Nginx as the base image
FROM nginx:alpine

# Copy your HTML files into the default nginx directory
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

