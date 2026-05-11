# Linux Development Environment Setup

自动化配置脚本，用于快速设置新 Linux 机器的开发环境。

## 功能特性

此脚本会自动安装和配置以下工具：

- ✅ **apt** - 更新包管理器
- ✅ **git** - 版本控制系统
- ✅ **zsh** - 强大的 shell
- ✅ **oh-my-zsh** - zsh 配置框架
- ✅ **zsh-syntax-highlighting** - 命令语法高亮插件
- ✅ **zsh-autosuggestions** - 命令历史建议插件
- ✅ **tmux** - 终端复用器
- ✅ **tmux 滚动历史** - 鼠标滚轮支持和 10000 行历史缓冲

## 快速开始

### 1. 下载脚本

```bash
# 克隆或下载此仓库
git clone <your-repo-url> ~/dot-files
cd ~/dot-files
```

### 2. 赋予执行权限

```bash
chmod +x setup.sh
```

### 3. 运行脚本

```bash
./setup.sh
```

脚本会交互式地询问每个步骤，你可以选择跳过某些安装。

## 脚本特性

### 🔒 安全性
- 所有操作都需要用户确认
- 自动备份现有配置文件（格式：`文件名.backup.YYYYMMDD_HHMMSS`）
- 检测已安装的软件，避免重复安装

### 🎨 用户友好
- 彩色输出，清晰的步骤提示
- 交互式确认，完全可控
- 详细的错误和警告信息

### ⚙️ 智能配置
- 自动配置 oh-my-zsh 插件
- 预配置 tmux 鼠标支持和滚动历史
- 优化的 tmux 配置（vi 模式、256 色支持、美化状态栏）

## 安装内容详解

### oh-my-zsh 插件

脚本会安装并启用以下插件：

1. **git** - git 命令别名和补全
2. **zsh-syntax-highlighting** - 实时语法高亮
3. **zsh-autosuggestions** - 基于历史的命令建议

插件配置会自动写入 `~/.zshrc`。

### tmux 配置

创建 `~/.tmux.conf` 包含以下特性：

- **鼠标支持** - 滚动、选择窗格、调整大小
- **10000 行历史** - 大容量滚动缓冲区
- **vi 模式** - 使用 vi 快捷键复制
- **美化状态栏** - 显示会话、窗口、时间
- **快捷键** - `Ctrl+b` 然后 `r` 重新加载配置

## 使用指南

### 切换到 zsh

脚本结束时会询问是否切换默认 shell，或手动执行：

```bash
chsh -s $(which zsh)
```

**注意：** 需要注销并重新登录才能生效。

### tmux 基本操作

启动 tmux：
```bash
tmux
```

常用快捷键（前缀键 `Ctrl+b`）：
- `Ctrl+b` + `c` - 创建新窗口
- `Ctrl+b` + `n` - 下一个窗口
- `Ctrl+b` + `p` - 上一个窗口
- `Ctrl+b` + `%` - 垂直分割窗格
- `Ctrl+b` + `"` - 水平分割窗格
- `Ctrl+b` + `r` - 重新加载配置

滚动历史：
- 鼠标滚轮直接滚动
- 或 `Shift+PageUp` / `Shift+PageDown`

### 验证安装

```bash
git --version
zsh --version
tmux -V
```

## 故障排除

### 权限问题

如果遇到权限错误，确保你有 sudo 权限：
```bash
sudo -v
```

### oh-my-zsh 安装失败

手动安装：
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 插件不生效

检查 `~/.zshrc` 中的 plugins 行：
```bash
grep "plugins=" ~/.zshrc
```

应该包含：
```bash
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
```

### tmux 鼠标滚动不工作

确认 `~/.tmux.conf` 包含：
```bash
set -g mouse on
```

重新加载配置：
```bash
tmux source-file ~/.tmux.conf
```

## 配置文件位置

- **zsh 配置**: `~/.zshrc`
- **tmux 配置**: `~/.tmux.conf`
- **oh-my-zsh**: `~/.oh-my-zsh/`
- **插件目录**: `~/.oh-my-zsh/custom/plugins/`

## 备份文件

脚本会自动备份以下文件（如果存在）：
- `~/.zshrc.backup.YYYYMMDD_HHMMSS`
- `~/.tmux.conf.backup.YYYYMMDD_HHMMSS`

## 系统要求

- **操作系统**: Linux (Debian/Ubuntu 系列)
- **包管理器**: apt
- **网络**: 需要互联网连接下载软件包
- **权限**: sudo 权限

## 自定义

### 修改 tmux 历史行数

编辑 `~/.tmux.conf`：
```bash
set -g history-limit 50000  # 改为 50000 行
```

### 添加更多 oh-my-zsh 插件

编辑 `~/.zshrc`：
```bash
plugins=(git zsh-syntax-highlighting zsh-autosuggestions docker kubectl)
```

查看可用插件：
```bash
ls ~/.oh-my-zsh/plugins/
```

## 卸载

### 卸载 oh-my-zsh
```bash
uninstall_oh_my_zsh
```

### 恢复默认 shell
```bash
chsh -s /bin/bash
```

### 删除配置文件
```bash
rm ~/.zshrc ~/.tmux.conf
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

---

**提示**: 首次运行建议在测试环境或虚拟机中验证，确保符合你的需求。
