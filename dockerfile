# 使用 Node.js 16 作为基础镜像
FROM node:16 AS build-stage

# 将当前工作目录设置为/app
WORKDIR /app

# 将 package.json 和 package-lock.json 复制到 /app 目录下
COPY package*.json ./

# 运行 npm install 安装依赖
RUN npm install

# 复制源代码到 /app 目录下
COPY . .

# 打包构建
RUN npm run build

# 使用 nginx:latest 作为生产环境镜像
FROM nginx:latest

# 从构建阶段复制构建后的代码到 nginx 镜像中
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制自定义的 Nginx 配置文件（如果有的话）
# COPY nginx.conf /etc/nginx/nginx.conf
MAINTAINER cchyi
RUN sed -i '2c listen 8080;' /etc/nginx/conf.d/default.conf
RUN sed -i '3c listen [::]:8080;' /etc/nginx/conf.d/default.conf

# 暴露容器的 8080 端口
EXPOSE 8080

# 启动 nginx 服务，监听8080端口
CMD ["nginx", "-g", "daemon off;"]