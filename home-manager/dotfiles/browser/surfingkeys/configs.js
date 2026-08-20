// https://github.com/brookhong/Surfingkeys/issues
// vietnamese keyboard bug for shortcuts like 'oo'-> 'ô'
// fcitx5 fix that bug but have bug when typing in omnibar must type enter to show suggestions

const {
  Front,
  Normal,
  RUNTIME,
  addSearchAlias,
  imap,
  imapkey,
  iunmap,
  map,
  mapkey,
  removeSearchAlias,
  tabOpenLink,
  unmap,
} = api;

/***********************
SECTION: SETTINGS
***********************/
settings.scrollStepSize = 200;
settings.defaultSearchEngine = "gg";

// Do not add `settings.autoFocusResults` -- no such setting in 1.18.0.

// Hosts where Surfingkeys is off, subdomains and ports included. No escaping needed.
// prettier-ignore
const BLOCKLIST_HOSTS = [
  "youtube.com",
  // "localhost",
  // "127.0.0.1",
  // "ninjaverse.xyz",
];

// Must be a real RegExp -- Surfingkeys patches RegExp.prototype.toJSON so it survives
// sendMessage. The anchor and lookahead keep it to the host: without them a domain also
// matches example.com/?q=<domain> and not<domain>.com.
const blocklistHostAlt = BLOCKLIST_HOSTS.map((h) =>
  h.replace(/\./g, "\\."),
).join("|");

settings.blocklistPattern = new RegExp(
  `^https?://([^/]+\\.)?(${blocklistHostAlt})(:\\d+)?(?=[/?#]|$)`,
);

/***********************
SECTION: KEY MAPPINGS
***********************/
// Passthrough mode
map("<Ctrl-v>", "<Alt-i>");

// Tab navigation -- built-in Ctrl-6 jumps to the last tab
map("J", "R");
map("K", "E");
map("H", "S");
map("L", "D");
map("[b", "B");
map("]b", "F");

// Close all tabs
map("gx", "gxx");

// still usable in insert mode
unmap("<Ctrl-i>");

imap("jk", "<Esc>");

// map("p", "cc");  // open the clipboard URL in a new tab
// imapkey("<Ctrl-u>", "Scroll up half page", () => Normal.scroll("pageUp"));
// imapkey("<Ctrl-d>", "Scroll down half page", () => Normal.scroll("pageDown"));

/***********************
SECTION: ALIASES
***********************/
["w", "s", "g", "e", "b", "y"].forEach((a) => removeSearchAlias(a));
unmap("on"); // frees the prefix for "ont" below
// prettier-ignore
[
  ["gg", "google",   "https://www.google.com/search?q="],
  ["tt", "taostats", "https://taostats.io/subnets/%s"],
  ["gh", "github",   "https://github.com/search?q="],
  ["np", "nixpkgs",  "https://search.nixos.org/packages?channel=unstable&query=%s"],
  ["nm", "mynixos",  "https://mynixos.com/search?q=%s"],
  ["nv", "nixvim",   "https://nix-community.github.io/nixvim/?search=%s"],
  ["yt", "youtube",  "https://www.youtube.com/results?search_query=%s"],
].forEach(([alias, name, url]) => addSearchAlias(alias, name, url));

mapkey("ont", "Open newtab", function () {
  tabOpenLink("www.google.com");
});

/***********************
SECTION: SHORTCUTS URLS
***********************/
// Match on origin + path, not raw string: otherwise "github.com/stars" also matches
// "github.com/starship/starship".
function urlMatcher(target) {
  const { origin, pathname } = new URL(target);
  const base = pathname.replace(/\/+$/, "");

  return (candidate) => {
    let parsed;
    try {
      parsed = new URL(candidate);
    } catch {
      return false; // about:blank, chrome://..., a tab still loading
    }
    if (parsed.origin !== origin) return false;
    if (!base) return true; // the entry is a whole domain
    return parsed.pathname === base || parsed.pathname.startsWith(`${base}/`);
  };
}

// Already there -> go back; open somewhere -> focus it; otherwise -> open it.
function toggleFocusUrl(url) {
  const matches = urlMatcher(url);

  if (matches(window.location.href)) {
    RUNTIME("goToLastTab");
    return;
  }

  // empty queryInfo scans every window, not just this one
  RUNTIME("getTabs", { queryInfo: {} }, ({ tabs }) => {
    const tab = Array.isArray(tabs)
      ? tabs.find(({ url: tabUrl }) => tabUrl && matches(tabUrl))
      : null;

    if (tab?.id != null) {
      RUNTIME("focusTab", { tabId: tab.id, windowId: tab.windowId });
    } else {
      tabOpenLink(url);
    }
  });
}

// "https://www.facebook.com/" -> "facebook.com"
// "http://10.0.0.1:20128/dashboard" -> "10.0.0.1:20128/dashboard"
function titleFromUrl(url) {
  const { host, pathname } = new URL(url);
  return host.replace(/^www\./, "") + pathname.replace(/\/+$/, "");
}

// [key, url, title] -- the third column only when the URL-derived name reads badly.
//
// No key may be a prefix of another: mapkey() silently drops the longer one, or lets the
// shorter erase the branch if registered the other way round, and the only warning is at
// `warn` level while logLevels defaults to `error`. Hence every github entry is "gh" plus
// exactly one character, with the homepage taking a dot.
// prettier-ignore
const SITES = [
  ["9r", "http://100.127.63.100:20128/dashboard", "9router"],
  ["fb", "https://www.facebook.com/"                       ],
  ["gh.", "https://github.com/"                             ],
  ["ghh", "https://github.com/Hoctotbachkhoa/hoctotbachkhoa"],
  ["ghn", "https://github.com/ninjaverse-xyz/ninjaverse"    ],
  ["ghs", "https://github.com/stars"                        ],
  ["gm", "https://mail.google.com/"                        ],
  ["ht", "https://hoctotbachkhoa.com/"                     ],
  ["nd", "https://app.netdata.cloud/"                      ],
  ["ex", "https://excalidraw.com/"                      ],
].map(([key, url, title]) => ({ key, url, title: title ?? titleFromUrl(url) }));

SITES.forEach(({ key, title, url }) =>
  mapkey(`<Space>${key}`, title, () => toggleFocusUrl(url)),
);

// A second way into the same list: type the name instead of the key.
//
// The "UserURLs" handler always opens a new tab even when the page is open, and its onEnter
// cannot be overridden from here. Way around: `openFocused` calls focusTab instead of
// openLink when a uid starts with "T", so look tabs up BEFORE opening the omnibar and stamp
// the uid onto entries already open.
mapkey("<Space><Space>", "Open saved site", () =>
  RUNTIME("getTabs", { queryInfo: {} }, ({ tabs }) => {
    const open = Array.isArray(tabs) ? tabs : [];

    Front.openOmnibar({
      type: "UserURLs",
      extra: SITES.map((site) => {
        const matches = urlMatcher(site.url);
        const tab = open.find(({ url }) => url && matches(url));

        return tab?.id != null
          ? { ...site, uid: `T${tab.windowId}:${tab.id}` }
          : site;
      }),
    });
  }),
);
