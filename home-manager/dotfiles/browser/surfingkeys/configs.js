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
map("<Ctrl-v>", "<Alt-i>");

// Tab navigation
map("J", "R");
map("K", "E");
map("H", "S");
map("L", "D");

// Close all tab
map("gx", "gxx");

// Open a URL in new tab (switch if already open)
// map("<Space><Space>", "t");

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
["w", "s", "g", "e", "b", "y"].forEach((a) => removeSearchAlias(a));
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
].forEach(([alias, name, url]) => addSearchAlias(alias, name, url));

mapkey("ont", "Open newtab", function () {
  tabOpenLink("www.google.com");
});

/***********************
SECTION: SHORTCUTS URLS
***********************/
// So khớp theo origin + path, không phải so chuỗi thô: nếu không, mốc
// "github.com/stars" sẽ khớp nhầm cả "github.com/starship/starship".
function urlMatcher(target) {
  const { origin, pathname } = new URL(target);
  const base = pathname.replace(/\/+$/, "");

  return (candidate) => {
    let parsed;
    try {
      parsed = new URL(candidate);
    } catch {
      return false; // about:blank, chrome://..., tab chưa load xong
    }
    if (parsed.origin !== origin) return false;
    if (!base) return true; // mốc là cả domain
    return parsed.pathname === base || parsed.pathname.startsWith(`${base}/`);
  };
}

// Đang ở đó rồi -> quay về tab trước; đã mở đâu đó -> nhảy tới; chưa có -> mở mới.
function toggleFocusUrl(url) {
  const matches = urlMatcher(url);

  if (matches(window.location.href)) {
    RUNTIME("goToLastTab");
    return;
  }

  // queryInfo rỗng = quét mọi cửa sổ, không riêng cửa sổ hiện tại
  RUNTIME("getTabs", { queryInfo: {} }, ({ tabs }) => {
    const tab = Array.isArray(tabs)
      ? tabs.find(({ url: tabUrl }) => tabUrl && matches(tabUrl))
      : null;

    if (tab?.id != null) {
      // windowId để background kéo luôn cửa sổ chứa tab lên trước
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

// [phím, url] — cột thứ ba là tên hiển thị, chỉ khai khi tên suy ra từ URL khó đọc
// prettier-ignore
const SITES = [
  ["9r", "http://100.127.63.100:20128/dashboard", "9router"],
  ["fb", "https://www.facebook.com/"                       ],
  ["gh", "https://github.com/"],
  ["ghh", "https://github.com/Hoctotbachkhoa/hoctotbachkhoa"],
  ["ghn", "https://github.com/ninjaverse-xyz/ninjaverse"    ],
  ["ghs", "https://github.com/stars"                        ],
  ["gm", "https://mail.google.com/"                        ],
  ["ht", "https://hoctotbachkhoa.com/"                     ],
  ["nd", "https://app.netdata.cloud/"                      ],
].map(([key, url, title]) => ({ key, url, title: title ?? titleFromUrl(url) }));

SITES.forEach(({ key, title, url }) =>
  mapkey(`<Space>${key}`, title, () => toggleFocusUrl(url)),
);

// Lối vào thứ hai cho cùng danh sách: gõ tên thay vì nhớ phím
mapkey("<Space><Space>", "Open saved site", () =>
  Front.openOmnibar({ type: "UserURLs", extra: SITES }),
);
