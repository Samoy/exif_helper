import { defineConfig } from "vitepress";
import { zh } from "./zh";
import pkg from "../package.json";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/exif_helper/",
  cleanUrls: true,
  title: "ExifHelper",
  outDir: "dist",
  description: "Read or write image exif without internet",
  themeConfig: {
    logo: "/logo.svg",
    langMenuLabel: "Languages",
    darkModeSwitchLabel: "Theme",
    lightModeSwitchTitle: "Switch to light mode",
    darkModeSwitchTitle: "Switch to dark mode",
    nav: [
      {
        text: pkg.version,
        items: [
          {
            text: "Changelog",
            link: "https://github.com/Samoy/exif_helper/blob/main/CHANGELOG.md",
          },
        ],
      },
    ],
    footer: {
      message:
        '<a href="./terms">Terms</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="./privacy">Privacy</a>',
      copyright: `Copyright © ${new Date().getFullYear()} Samoy Young`,
    },
    notFound: {
      quote:
        "Please check that you have entered the correct URL, or click the button below back to the home page.",
    },
  },
  locales: {
    root: {
      label: "English",
      lang: "en-US",
    },
    zh: {
      label: "简体中文",
      ...zh,
    },
  },
});
