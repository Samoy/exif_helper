---
layout: home
---


<script lang="ts" setup>
import { ref, onMounted } from 'vue';
const platforms = [{
label: 'Windows',
icon: '/exif_helper/Windows.svg'
}, {
label: 'MacOS',
icon: '/exif_helper/MacOS.svg'
},{
label: 'Linux',
icon: '/exif_helper/Linux.svg'
},{
label: 'Android',
icon: '/exif_helper/Android.svg'
},{
label: 'iOS',
icon: '/exif_helper/iOS.svg'
}];

const currentPlatform = ref('Unknown');

onMounted(() => {
currentPlatform.value = sessionStorage.getItem('platform') || getCurrentPlatform();

function getCurrentPlatform(): String {
  const userAgent = navigator.userAgent;
  if (/Windows/i.test(userAgent)) {
    return 'Windows';
  } else if (/Macintosh/i.test(userAgent) || /MacIntel/i.test(userAgent)) {
    return 'macOS';
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

</script>

<div class="download">
<h1>
<img src="/logo.svg" alt="ExifHelper">
</h1>
<h1>Download ExifHelper</h1>
<div class="download-buttons">
<button class="download-button" :class="{ 'active': currentPlatform === label }" v-for="{label,icon} in platforms" :key="label"
@click="changePlatform(label)">
<img class="icon" :src="icon"/> {{label}}
</button>
</div>
<div class="download-area">
<template v-if="currentPlatform === 'Windows'">
 <h4>Windows Downloads</h4>
<div>
<h6>Binaries</h6>
<a class="download-link">⬇️ EXE</a>
<a class="download-link">⬇️ MSI</a>
<a class="download-link">⬇️ ZIP</a>
</div>
<div>
<div>
<h6>Microsoft Store</h6>
<a class="download-link">
<img src="/microsoft-store.svg"/>
</a>
</div>
</div>
</template>
<template v-if="currentPlatform === 'MacOS'">
 <h4>MacOS Downloads</h4>
<div>
<h6>Binaries</h6>
<a class="download-link">⬇️ DMG</a>
</div>
<div>
<div>
<h6>Apple Store</h6>
<a class="download-link">
<img src="/apple-store.svg"/>
</a>
</div>
</div>
</template>
<template v-if="currentPlatform === 'Linux'">
 <h4>Linux Downloads</h4>
<div>
<h6>Binaries</h6>
<a class="download-link">⬇️ TAR</a>
<a class="download-link">⬇️ DEB</a>
</div>
<div>
</div>
</template>
<template v-if="currentPlatform === 'Android'">
 <h4>Android Downloads</h4>
<div>
<h6>Binaries</h6>
<a class="download-link">⬇️ APK</a>
</div>
<div>
<h6>Google Play</h6>
<a class="download-link">
<img src="/google-play.svg"/>
</a>
</div>
<div>
</div>
</template>
<template v-if="currentPlatform === 'iOS'">
 <h4>iOS Downloads</h4>
<div>
<h6>Apple Store</h6>
<a class="download-link">
<img src="/apple-store.svg"/>
</a>
</div>
<div>
</div>
</template>
</div>
</div>
