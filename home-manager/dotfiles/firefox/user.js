// ── UI ────────────────────────────────────────────────────────────────────────
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);                          // compact density
user_pref("browser.tabs.tabMinWidth", 76);
user_pref("browser.tabs.tabClipWidth", 76);
user_pref("toolkit.cosmeticAnimations.enabled", false);     // tắt animations
user_pref("browser.fullscreen.animate", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("extensions.pocket.enabled", false);              // tắt Pocket

// ── Privacy ───────────────────────────────────────────────────────────────────
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.fingerprintingProtection", true);
user_pref("network.cookie.cookieBehavior", 1);              // block third-party cookies
user_pref("browser.send_pings", false);
user_pref("beacon.enabled", false);

// ── Telemetry ─────────────────────────────────────────────────────────────────
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);

// ── DNS over HTTPS ────────────────────────────────────────────────────────────
user_pref("network.trr.mode", 2);                           // DoH với fallback
user_pref("network.trr.uri", "https://cloudflare-dns.com/dns-query");

// ── Performance ───────────────────────────────────────────────────────────────
user_pref("gfx.webrender.all", true);                       // WebRender GPU
user_pref("layers.acceleration.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);

// ── userChrome.css support ────────────────────────────────────────────────────
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
