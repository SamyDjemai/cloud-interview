ARG PORT=3000
ARG NODE_VERSION=18
ARG ALPINE_VERSION=3.17

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

ENV NODE_ENV=production
WORKDIR /app

# Use Tini to avoid running as PID 1: https://github.com/krallin/tini
RUN apk add --no-cache tini~=0.19.0 && chown node:node .

# Change the user to node (UID: 1000, GID: 1000)
USER node

# Copy only files needed for package installation
COPY --chown=node:node package.json yarn.lock* ./

RUN yarn

COPY --chown=node:node . .

EXPOSE ${PORT}

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["yarn", "start"]
