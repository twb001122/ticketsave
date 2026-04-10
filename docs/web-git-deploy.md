# Web Git 部署流程

这个项目的 Web 端使用 GitHub Actions 自动部署到 1Panel 服务器。

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
5. 合并到 `main` 后，GitHub Actions 会自动部署到服务器。

## GitHub Secrets

在 GitHub 仓库的 `Settings > Secrets and variables > Actions` 里配置：

```text
DEPLOY_HOST=156.229.28.69
DEPLOY_USER=root
DEPLOY_PORT=22
DEPLOY_PATH=/opt/xysg-web
DEPLOY_CONTAINER=xysg-web
DEPLOY_SSH_KEY=<部署专用 SSH 私钥>
```

如果服务器禁用了 root 登录，把 `DEPLOY_USER` 换成你实际使用的 SSH 用户，并确保它能写入 `/opt/xysg-web` 且能执行 `docker restart xysg-web`。

## 服务器 SSH key

建议生成一把只给 GitHub Actions 使用的部署 key：

```bash
ssh-keygen -t ed25519 -C "github-actions-xysg-web" -f ~/.ssh/xysg_web_deploy
```

把公钥内容加入服务器的：

```text
~/.ssh/authorized_keys
```

把私钥内容填入 GitHub Secret：

```text
DEPLOY_SSH_KEY
```

## 服务器保留文件

自动部署会同步 `web/` 到 `/opt/xysg-web`，但不会覆盖：

```text
/opt/xysg-web/.env
/opt/xysg-web/node_modules
/opt/xysg-web/data
```

线上数据目录也不在 Git 部署范围内：

```text
/www/wwwroot/xysg-data
```

## 手动触发

GitHub Actions 支持 `workflow_dispatch`。如果需要手动重新部署，可以在 GitHub 的 `Actions > Deploy Web > Run workflow` 里选择 `main` 后运行。

## 回滚

回滚代码时，把 `main` 回退到上一个正常 commit，然后重新触发 `Deploy Web`。数据库和 `.env` 不会被部署覆盖。
