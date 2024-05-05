---
layout: home
---


<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { withBase } from 'vitepress'
const platforms = [{
label: 'Windows',
icon: '/Windows.svg'
}, {
label: 'MacOS',
icon: '/MacOS.svg'
},{
label: 'Linux',
icon: '/Linux.svg'
},{
label: 'Android',
icon: '/Android.svg'
},{
label: 'iOS',
icon: '/iOS.svg'
}];

const currentPlatform = ref('Unknown');

onMounted(() => {
  
currentPlatform.value = sessionStorage.getItem('platform') || getCurrentPlatform();

function getCurrentPlatform(): String {
  const userAgent = navigator.userAgent;
  if (/Windows/i.test(userAgent)) {
    return 'Windows';
  } else if (/Macintosh/i.test(userAgent) || /MacIntel/i.test(userAgent)) {
    return 'MacOS';
  } else if (/Linux/i.test(userAgent)) {
    return 'Linux';
  }

  if (/Android/i.test(userAgent)) {
    return 'Android';
  } else if (/iPhone|iPad|iPod|iOS/i.test(userAgent)) {
    return 'iOS';
  }

  return 'Unknown';
}

})

function changePlatform(platform: String) {
  currentPlatform.value = platform;
  sessionStorage.setItem('platform', platform);
}

function wip(e){
  e.preventDefault();
  alert('敬请期待！');
}

</script>

<div class="download">
<h1>
<img src="/logo.svg" alt="Exif小助手">
</h1>
<h1>下载Exif小助手</h1>
<div class="download-buttons">
<button class="download-button" :class="{ 'active': currentPlatform === label }" v-for="{label,icon} in platforms" :key="label"
@click="changePlatform(label)">
<img class="icon" :src="withBase(icon)"/> {{label}}
</button>
</div>
<div class="download-area">
<template v-if="currentPlatform === 'Windows'">
 <h4>Windows下载</h4>
<div>
<h6>二进制文件</h6>
<a class="download-link" target="_blank" download :href="withBase('/release/Exif小助手_windows_x64.exe')">⬇️ EXE</a>
<a class="download-link" target="_blank" download :href="withBase('/release/Exif小助手_windows_x64.msix')">⬇️ MSIX</a>
<a class="download-link" target="_blank" download :href="withBase('/release/Exif小助手_windows_x64.zip')">⬇️ ZIP</a>
</div>
<div>
<div>
<h6>Microsoft Store</h6>
<a class="download-link" @click="wip">
<img src="/microsoft-store.svg"/>
</a>
</div>
</div>
</template>
<template v-if="currentPlatform === 'MacOS'">
 <h4>MacOS下载</h4>
<div>
<h6>二进制文件</h6>
<a class="download-link" target="_blank" download :href="withBase('/release/Exif小助手.dmg')">⬇️ DMG</a>
</div>
<div>
<div>
<h6>Apple Store</h6>
<a class="download-link" @click="wip">
<img src="/apple-store.svg"/>
</a>
</div>
</div>
</template>
<template v-if="currentPlatform === 'Linux'">
 <h4>Linux下载</h4>
<div>
<h6>二进制文件</h6>
<a class="download-link" target="_blank" download :href="withBase('/release/Exif小助手.tar.gz')">⬇️ TAR</a>
</div>
<div>
</div>
</template>
<template v-if="currentPlatform === 'Android'">
 <h4>Android下载</h4>
<div>
<h6>二进制文件</h6>
<a class="download-link" target="_blank" download :href="withBase('/release/Exif小助手.apk')">⬇️ APK</a>
</div>
<div>
<h6>Google Play</h6>
<a class="download-link" @click="wip">
<img src="/google-play.svg"/>
</a>
</div>
<div>
</div>
</template>
<template v-if="currentPlatform === 'iOS'">
 <h4>iOS下载</h4>
<div>
<h6>Apple Store</h6>
<a class="download-link" @click="wip">
<img src="/apple-store.svg"/>
</a>
</div>
<div>
</div>
</template>
</div>
</div>
