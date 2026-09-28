<h1 align="center"><img width="40%" src="./brand.png" alt="soppy-gitea" /></h1>

<span align="center"> 

[English](README.md) | [简体中文](README.zh-cn.md) 

</span>

**Gitea 1.27.3** 的像素风格主题 —— 浅色与深色两套，纯 CSS：不改动 JavaScript、模板或 Go
代码。

主题是一个*覆盖层*：Gitea 永远先加载自带的基础样式表，主题文件在其后加载，因此主题只覆盖
需要改的部分。

## 主题包含什么

- **像素字体** —— 全套界面使用 Ark Pixel 12px Monospaced（含中日韩字形），代码使用
  Fira Code / Fira Mono
- **两套完整色板** —— 冷调中性的浅色表面与深色变体，各自填满 Gitea 的整个 `:root`
  token 阶梯，不会漏出上游默认值
- **方正几何** —— 零圆角、1px 边框、硬偏移阴影与凸起/凹陷斜面，取代 Gitea 的圆角与模糊投影
- **两个变体都通过 AA 对比度**（实测）—— 包括 Gitea 用硬编码白字绘制的彩色状态徽章与危险按钮
- **品牌美术** —— 首页主视觉与字标，以及配套 favicon

## 安装

### 从 Release 安装（推荐）

每个 [release](../../releases) 附带 `soppy-<version>.zip`，压缩包目录结构与 Gitea 实例的
`custom/public/` 完全对应，因此安装只需一次拷贝：

```sh
unzip soppy-<version>.zip -d /tmp/soppy
cp -r /tmp/soppy/public/. /path/to/gitea/custom/public/   # $GITEA_CUSTOM
```

包内含两套主题 CSS、像素字体、首页插画、授权文件，以及两个 SVG 品牌包装文件。

### 从源码安装

```sh
scripts/build.sh    # 生成 dist/theme-soppy-light.css、dist/theme-soppy-dark.css
scripts/package.sh  # 生成 dist/soppy-<version>.zip（与 release 包结构一致）
```

把两个 CSS 文件拷进 `<custom>/public/assets/css/` 时，**必须同时**把 `assets/` 目录拷为
`<custom>/public/assets/soppy/` —— 样式表通过 `/assets/soppy/…` 引用像素字体和首页插画，
只拷 CSS 会让这些资源 404。

### 注册主题

修改 `app.ini` 后重启 Gitea：

```ini
[ui]
THEMES = gitea-auto,gitea-light,gitea-dark,soppy-light,soppy-dark
DEFAULT_THEME = soppy-dark   ; 可选
```

然后在 **设置 → 外观** 中选择主题。

### 说明

- 代码字体（Fira Code / Fira Mono）通过 `@import` 从 Google Fonts 加载；服务器无外网时
  代码会回退到系统等宽字体栈。正文字体已随包分发，始终可用。
- Gitea 对 `/assets/*` 有 6 小时缓存；升级后“主题没变化”通常是浏览器缓存所致。
- 卸载：删除两个 `theme-soppy-*.css`，从 `THEMES` 中移除 `soppy-*`，重启即可。

## 授权

MIT —— 见 [LICENSE](LICENSE)。

随包分发的像素字体（Ark Pixel 12px Monospaced）以 **SIL Open Font License 1.1** 授权 ——
见 `assets/OFL.txt`，该文件必须与字体一同分发。
