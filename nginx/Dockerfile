FROM aditirvan/phusion-passenger-nginx-alpine:latest
RUN apk add --update nginx && rm -rf /var/cache/apk/*
RUN mkdir -p /tmp/nginx/client-body

CMD ["nginx", "-g", "daemon off;"]