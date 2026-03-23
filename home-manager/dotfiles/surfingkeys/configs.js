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

// Open a URL in current tab
map("<Space><Space>", "go");

// Tab forward and backward
map("[b", "B");
map("]b", "F");
// Switch to last used tab with Ctrl-6

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

// leader key
api.mapkey("<Space>g", "Search Google via omnibar", function () {
  api.Front.openOmnibar({ type: "SearchEngine", extra: "gg" });
});
/***********************
SECTION: SHORTCUTS URLS
***********************/
// prettier-ignore
[
  ["ogH", "Open Github",            "https://github.com"],
  ["ogS", "Open Github stars page", "https://github.com/stars"],
  ["ofB", "Open Facebook",          "https://www.facebook.com/"],
].forEach(([key, desc, url]) => api.mapkey(key, desc, () => window.location.replace(url)));
