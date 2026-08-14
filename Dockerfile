# 1. 使用体积小且安全的 Node.js 镜像
FROM node:18-slim

# 1.5 修复 Choreo Trivy 安全扫描中 libgnutls30 的 Critical 漏洞
# CVE-2026-33845 / CVE-2026-42010，基础镜像自带旧版，必须显式升级
RUN apt-get update && apt-get install -y --no-install-recommends libgnutls30 && rm -rf /var/lib/apt/lists/*

# 2. 设置容器内的工作目录
WORKDIR /home/choreoapp

# 3. 拷贝 package 描述文件，利用缓存加速构建
COPY package*.json ./
RUN npm install --production

# 4. 拷贝您所有原封不动的项目文件（包括您的原版 index.js）
COPY . .

# 5. 【绝对核心：解决 Failed to retrieve build logs 的权限拦截】
# Choreo 强制要求非 root 用户运行，必须创建并使用 UID 10001
RUN adduser --disabled-password --gecos "" --uid 10001 choreouser && \
    chown -R 10001:10001 /home/choreoapp
USER 10001

# 6. 【关键：配合您的 index.js 兜底逻辑】明确向平台宣告使用 3000 端口
EXPOSE 3000

# 7. 启动您的程序
CMD ["node", "index.js"]
