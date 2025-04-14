// ==UserScript==
// @name         Bypass Blokir Situs Dewasa Populer
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Redirect otomatis ke proxy jika situs dewasa diblokir ISP Indonesia
// @author       Kamu
// @match        *://*.pornhub.com/*
// @match        *://*.xvideos.com/*
// @match        *://*.xnxx.com/*
// @match        *://*.redtube.com/*
// @match        *://*.youporn.com/*
// @match        *://*.tube8.com/*
// @match        *://*.spankbang.com/*
// @match        *://*.hclips.com/*
// @match        *://*.efukt.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Gunakan proxy site untuk unblock
    const proxyBase = "https://www.proxysite.com/go.php?u=";
    const currentUrl = window.location.href;

    // Hindari loop jika sudah di dalam proxysite
    if (!currentUrl.includes("proxysite.com")) {
        const encodedUrl = encodeURIComponent(currentUrl);
        window.location.href = proxyBase + encodedUrl;
    }
})();
