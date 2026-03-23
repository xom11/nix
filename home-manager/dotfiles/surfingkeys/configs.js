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
api.removeSearchAlias("w");
api.removeSearchAlias("s");
api.removeSearchAlias("g");
api.removeSearchAlias("e");
api.removeSearchAlias("b");
api.removeSearchAlias("y");
unmap("on");
api.addSearchAlias("gg", "google", "https://www.google.com/search?q=");
api.addSearchAlias("tt", "taostats", "https://taostats.io/subnets/%s");
api.addSearchAlias("gh", "github", "https://github.com/search?q=");
api.addSearchAlias(
  "np",
  "nixpkgs",
  "https://search.nixos.org/packages?channel=unstable&query=%s",
);
api.addSearchAlias("nm", "mynixos", "https://mynixos.com/search?q=%s");
api.addSearchAlias(
  "nv",
  "nixvim",
  "https://nix-community.github.io/nixvim/?search=%s",
);
api.addSearchAlias(
  "yt",
  "youtube",
  "https://www.youtube.com/results?search_query=%s",
);

api.mapkey("ont", "Open newtab", function () {
  api.tabOpenLink("www.google.com");
});

// leader key
api.mapkey('<Space>g', 'Search Google via omnibar', function() {
  api.Front.openOmnibar({type: "SearchEngine", extra: "gg"});
});
/***********************
SECTION: SHORTCUTS URLS
***********************/
api.mapkey("ogH", "Open Github", function () {
  window.location.replace("https://github.com");
});
api.mapkey("ogS", "Open github stars page ", function () {
  window.location.replace("https://github.com/stars");
});
api.mapkey("ofB", "Open facebook ", function () {
  window.location.replace("https://www.facebook.com/");
});

