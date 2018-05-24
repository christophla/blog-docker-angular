# #############################################################################
# Development docker image with support for Angular 5
#
FROM node:10

LABEL Maintainer = Christopher Town <christopher@christophertown.com>
LABEL Name = Docker Angular App


# #############################################################################
# Cache layer with package.json for node_modules 
#
ADD package.json package-lock.json ./tmp/
RUN cd /tmp && npm i npm@latest -g && npm install && npm i -g nodemon
RUN mkdir -p /home/app/angular-app && cp -a /tmp/node_modules /home/app/angular-app


# #############################################################################
# Application Code
#
COPY . /home/app/angular-app


# #############################################################################
# Expose
#
WORKDIR /home/app/angular-app
EXPOSE 4200


# #############################################################################
# Polling for Windows
# 
ENTRYPOINT ["/bin/bash", "-c", "if [ \"$ENABLE_POLLING\" = \"enabled\" ]; then npm run start:docker:poll; else npm run start:docker; fi"]


# #############################################################################
