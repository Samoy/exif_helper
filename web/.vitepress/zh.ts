import { defineConfig } from "vitepress";
import pkg from "../package.json"; 

export const zh = defineConfig({
  lang: "zh-Hans",
  title: "Exif小助手",
  description: "一个无需网络即可读取和修改图片Exif信息的小工具",

  themeConfig: {
    nav: [
      {
        text: pkg.version,
        items: [
          {
            text: "更新日志",
            link: "https://github.com/Samoy/exif_helper/blob/main/CHANGELOG.md",
          },
        ],
      },
    ],
    footer: {
      message:
        '<a href="./terms">服务协议</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="./privacy">隐私政策</a>',
      copyright: `版权所有 © ${new Date().getFullYear()} Samoy Young`,
    },
    returnToTopLabel: "返回顶部",
    langMenuLabel: "多语言",
    darkModeSwitchLabel: "主题",
    lightModeSwitchTitle: "切换到浅色模式",
    darkModeSwitchTitle: "切换到深色模式",
    notFound: {
      title: "页面飞走了",
      quote: "请检查您输入的网址是否正确，或点击以下按钮返回主页。",
      linkLabel: "返回主页",
      linkText: "返回主页",
    },
  },
});
