FROM node:latest AS builder

RUN mkdir -p /build

WORKDIR /build

COPY . .

RUN yarn && \
	yarn build

FROM nginx:latest AS image

RUN echo 'server {\
  root /usr/share/nginx/html;\
  index index.html;\
\
  location / {\
    try_files $uri $uri/ /index.html;\
  }\
\
  location ~* \.(?:ico|css|js|gif|jpe?g|png)$ {\
    # Some basic cache-control for static files to be sent to the browser\
    expires max;\
    add_header Pragma public;\
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";\
  }\
\
}' > /etc/nginx/conf.d/default.conf 

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /build/build /usr/share/nginx/html
