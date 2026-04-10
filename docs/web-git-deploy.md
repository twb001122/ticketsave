# Web 手动 Git 部署流程

这个项目的 Web 端使用手动 Git 部署到 1Panel 服务器。流程是：本地开发并 push 到 GitHub，然后登录服务器执行 `git pull`、构建、重启 1Panel Node 运行环境。

## 日常开发

1. 从 `main` 新建开发分支。
2. 在本地修改 `web/`。
3. 本地验证：

   ```bash
   cd web
   npm test
   npm run build
   ```

4. 提交并 push 分支。
5. 合并到 `main` 后，登录服务器手动部署。

## 服务器首次准备

推荐在服务器上保留一个完整仓库目录：

```bash
cd /opt
git clone https://github.com/twb001122/ticketsave.git ticketsave
cd /opt/ticketsave
```

如果服务器已经有 `/opt/xysg-web/.env`，复制到新的仓库 Web 目录：

```bash
cp /opt/xysg-web/.env /opt/ticketsave/web/.env
```

然后在 1Panel 里把 Node 运行环境 `xysg-web` 的源码目录改成：

```text
/opt/ticketsave/web
```

如果 1Panel 不允许直接改源码目录，就重新创建一个 Node 运行环境，源码目录同样填 `/opt/ticketsave/web`，端口仍用 `3008`，容器名仍用 `xysg-web`。

## 每次部署

登录服务器后执行：

```bash
cd /opt/ticketsave
git fetch origin
git checkout main
git pull --ff-only origin main
cd web
npm ci
npm run build
docker restart xysg-web
```

如果你想先确认版本，可以在 `git pull` 后执行：

```bash
git log --oneline -1
```

## 服务器保留数据

`.env` 留在服务器，不提交进 Git：

```text
/opt/ticketsave/web/.env
```

线上数据目录由 `.env` 的 `DATA_DIR` 指向，不在 Git 仓库里：

```text
/www/wwwroot/xysg-data
```

## 回滚

在服务器仓库里查看最近提交：

```bash
cd /opt/ticketsave
git log --oneline -5
```

回到指定版本：

```bash
git checkout <commit-sha>
cd web
npm ci
npm run build
docker restart xysg-web
```

确认恢复后，再决定是否把 GitHub 的 `main` 回退到对应版本。数据库和 `.env` 不会被 Git 操作覆盖。
