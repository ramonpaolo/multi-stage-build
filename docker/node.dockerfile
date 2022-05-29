FROM node:14.17-alpine AS appbuild

WORKDIR /app

COPY ./ ./

RUN yarn build

# ---------

FROM node:14.17-alpine AS apptest

WORKDIR /app

COPY --from=appbuild /app ./

ENV NODE_TLS_REJECT_UNAUTHORIZED='0'

RUN yarn test:docker

# ---------

FROM node:14.17-alpine

WORKDIR /app

EXPOSE 3000

COPY --from=apptest /app/dist ./dist
COPY --from=apptest /app/package.json /app/yarn.lock ./

RUN yarn install --production

USER node

CMD ["yarn", "start"]