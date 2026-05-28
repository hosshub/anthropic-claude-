FROM node:22-alpine
WORKDIR /app
COPY server.mjs tayyibat_rules.json ./
ENV PORT=8787
EXPOSE 8787
# مرّر ANTHROPIC_API_KEY (و APP_TOKEN اختياري) كمتغيّرات بيئة عند التشغيل:
#   docker run -e ANTHROPIC_API_KEY=sk-ant-... -p 8787:8787 tayyibat-proxy
CMD ["node", "server.mjs"]
