// https://github.com/brookhong/Surfingkeys/issues
// vietnamese keyboard bug for shortcuts like 'oo'-> 'ô'
// fcitx5 fix that bug but have bug when typing in omnibar must type enter to show suggestions

const {
  Clipboard,
  Front,
  Hints,
  Normal,
  RUNTIME,
  Visual,
  aceVimMap,
  addSearchAlias,
  cmap,
  getClickableElements,
  imap,
  imapkey,
  iunmap,
  map,
  mapkey,
  readText,
  removeSearchAlias,
  tabOpenLink,
  unmap,
  unmapAllExcept,
  vmapkey,
  vunmap,
} = api;

/***********************
SECTION: SETTINGS
***********************/
// Scroll speed
settings.scrollStepSize = 200;

// Disable surfingkeys on specific URLs
settings.blocklistPattern =
  /https?:\/\/(www\.youtube\.com|localhost(:\d+)?|127\.0\.0\.1(:\d+)?|.*ninjaverse\.xyz).*/;

// Default search engine
settings.defaultSearchEngine = "gg";

// Do not auto-focus the first result in omnibar (allows Enter to search raw input)
settings.autoFocusResults = false;

/***********************
SECTION: KEY MAPPINGS
***********************/
// Open Clipboard URL in new tab
// map("p", "cc");

// Passthrough mode
api.map("<Ctrl-v>", "<Alt-i>");

// Tab navigation
map("J", "R");
map("K", "E");
map("H", "S");
map("L", "D");

// Close all tab
map("gx", "gxx");

// Open a URL in new tab (switch if already open)
map("<Space><Space>", "t");

// Tab forward and backward
map("[b", "B");
map("]b", "F");
// Switch to last used tab with Ctrl-6

// Unmap ctrl i ; still work in insert mode
unmap("<Ctrl-i>");
// iunmap("<Ctrl-i>");

// Escape insert mode with jk
imap("jk", "<Esc>");

// Scroll page in insert mode
// imapkey("<Ctrl-u>", "Scroll up half page", function () {
//   Normal.scroll("pageUp");
// });
// imapkey("<Ctrl-d>", "Scroll down half page", function () {
//   Normal.scroll("pageDown");
// });

/***********************
SECTION: ALIASES
***********************/
["w", "s", "g", "e", "b", "y"].forEach((a) => api.removeSearchAlias(a));
unmap("on");
// prettier-ignore
[
  ["gg", "google",   "https://www.google.com/search?q="],
  ["tt", "taostats", "https://taostats.io/subnets/%s"],
  ["gh", "github",   "https://github.com/search?q="],
  ["np", "nixpkgs",  "https://search.nixos.org/packages?channel=unstable&query=%s"],
  ["nm", "mynixos",  "https://mynixos.com/search?q=%s"],
  ["nv", "nixvim",   "https://nix-community.github.io/nixvim/?search=%s"],
  ["yt", "youtube",  "https://www.youtube.com/results?search_query=%s"],
].forEach(([alias, name, url]) => api.addSearchAlias(alias, name, url));

api.mapkey("ont", "Open newtab", function () {
  api.tabOpenLink("www.google.com");
});

/***********************
SECTION: SHORTCUTS URLS
***********************/
function toggleFocusUrl(url) {
  const matchesUrl = (candidateUrl) => candidateUrl.startsWith(url);

  if (matchesUrl(window.location.href)) {
    api.RUNTIME("goToLastTab");
    return;
  }

  api.RUNTIME("getTabs", { queryInfo: { currentWindow: true } }, ({ tabs }) => {
    const tab = Array.isArray(tabs)
      ? tabs.find(({ url: tabUrl }) => tabUrl && matchesUrl(tabUrl))
      : null;

    if (tab?.id != null) {
      api.RUNTIME("focusTab", { tabId: tab.id });
    } else {
      api.tabOpenLink(url);
    }
  });
}

// prettier-ignore
[
  // ["<Space>gh", "GitHub",            "https://github.com"],
  ["<Space>9r", "9router",     "http://100.127.63.100:20128/dashboard"],
  ["<Space>fb", "Facebook",          "https://www.facebook.com/"],
  ["<Space>gh", "GitHub hoctotbachkhoa",            "https://github.com/Hoctotbachkhoa/hoctotbachkhoa"],
  ["<Space>gn", "GitHub ninjaverse",            "https://github.com/ninjaverse-xyz/ninjaverse"],
  ["<Space>gs", "GitHub stars page", "https://github.com/stars"],
  ["<Space>ht", "hoctotbachkoa",     "https://hoctotbachhoa.com/"],
  ["<Space>nd", "netdata",     "https://app.netdata.cloud/"],
].forEach(([key, desc, url]) => api.mapkey(key, desc, () => toggleFocusUrl(url)));
