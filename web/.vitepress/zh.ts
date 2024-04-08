import {defineConfig, type DefaultTheme} from 'vitepress'


export const zh = defineConfig({
    lang: 'zh-Hans',
    title: 'Exif小助手',
    description: '一个无需网络即可读取和修改图片Exif信息的小工具',

    themeConfig: {
        footer: {
            copyright: `版权所有 © ${new Date().getFullYear()} Samoy Young`
        },

        langMenuLabel: '多语言',
        darkModeSwitchLabel: '主题',
        lightModeSwitchTitle: '切换到浅色模式',
        darkModeSwitchTitle: '切换到深色模式'
    }
})
