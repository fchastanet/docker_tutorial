FROM node:dubnium-alpine

RUN npm install -g @vue/cli

# Copy or mount node app here
WORKDIR /data/

EXPOSE 8080

ENTRYPOINT ["/entrypoint/entrypoint.sh"]

CMD ["npm", "start"]



