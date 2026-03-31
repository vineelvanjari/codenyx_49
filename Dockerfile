# Step 1: Build the Flutter Web application
FROM cirrusci/flutter:stable AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# Step 2: Serve the application using Nginx
FROM nginx:alpine

# Copy the built web files to Nginx share directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration if needed
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
