// ==UserScript==
// @name         Universal Title Freezer
// @namespace    http://tampermonkey.net/
// @version      1.2
// @description  Keep web titles fixed for specific PWA/App modes
// @author       Gemini
// @match        *://gemini.google.com/*
// @match        *://www.youtube.com/*
// @match        *://www.messenger.com/*
// @match        *://keep.google.com/*
// @match        *://discord.com/*
// @match        *://web.telegram.org/*
// @match        *://www.notion.so/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // 1. Map hostnames to desired titles
    const titleMap = {
        "gemini.google.com": "Google Gemini",
        "youtube.com": "YouTube",
        "messenger.com": "Messenger",
        "keep.google.com": "Google Keep",
        "discord.com": "Discord",
        "telegram.org": "Telegram",
        "notion.so": "Notion"
    };

    // 2. Identify the fixed title for the current site
    const host = window.location.hostname;
    const fixedTitle = Object.keys(titleMap).find(key => host.includes(key)) 
                       ? titleMap[Object.keys(titleMap).find(key => host.includes(key))] 
                       : null;

    if (fixedTitle) {
        // 3. Freeze the document.title property
        Object.defineProperty(document, 'title', {
            get: () => fixedTitle,
            set: () => fixedTitle,
            configurable: false
        });

        // 4. Force set initial title
        document.title = fixedTitle;

        // 5. Observer to prevent title tag manipulation (for SPAs like YouTube/Telegram)
        const observer = new MutationObserver(() => {
            if (document.title !== fixedTitle) document.title = fixedTitle;
        });
        
        observer.observe(document.documentElement, {
            subtree: true,
            childList: true,
            characterData: true
        });
    }
})();