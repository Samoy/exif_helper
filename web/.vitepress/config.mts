import {defineConfig} from 'vitepress'
import {zh} from "./zh";

// https://vitepress.dev/reference/site-config
export default defineConfig({
    base: '/exif_helper/',
    cleanUrls: true,
    title: "Exif Helper",
    outDir:'dist',
    description: "Read or write image exif without internet",
    themeConfig: {
        logo: '/logo.svg',
        langMenuLabel: 'Languages',
        darkModeSwitchLabel: 'Theme',
        lightModeSwitchTitle: 'Switch to light mode',
        darkModeSwitchTitle: 'Switch to dark mode',
        footer: {
            message: '<a href="./terms">Terms</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="./privacy">Privacy</a>',
            copyright: `Copyright © ${new Date().getFullYear()} Samoy Young`
        },
    },
    locales: {
        root: {
            label: 'English',
            lang: 'en-US'
        },
        zh: {
            label: '中文',
            ...zh
        },
    }
})
