import {defineConfig} from 'vitepress'
import {zh} from "./zh";

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "Exif Helper",
    description: "Read or write image exif without internet.",
    themeConfig: {
        logo: '/logo.svg',
        langMenuLabel: 'Languages',
        darkModeSwitchLabel: 'Theme',
        lightModeSwitchTitle: 'Switch to light mode',
        darkModeSwitchTitle: 'Switch to dark mode',
        footer: {
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
