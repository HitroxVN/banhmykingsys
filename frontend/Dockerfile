# dockerfile phía frontend
FROM node:24-alpine AS build
WORKDIR /build

ARG VITE_API_BASE_URL=""
ARG VITE_BACKEND_URL=""
ARG VIETQR_BANK_ID=""
ARG VIETQR_ACCOUNT_NO=""
ARG VIETQR_ACCOUNT_NAME=""
ARG VIETQR_TEMPLATE=""
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL \
    VITE_BACKEND_URL=$VITE_BACKEND_URL \
    VIETQR_BANK_ID=$VIETQR_BANK_ID \
    VIETQR_ACCOUNT_NO=$VIETQR_ACCOUNT_NO \
    VIETQR_ACCOUNT_NAME=$VIETQR_ACCOUNT_NAME \
    VIETQR_TEMPLATE=$VIETQR_TEMPLATE

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine AS runtime
COPY --from=build /build/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
