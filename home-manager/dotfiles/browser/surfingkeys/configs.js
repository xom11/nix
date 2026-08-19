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

// Đừng thêm `settings.autoFocusResults` — tên đó không tồn tại trong 1.18.0.

// Tắt Surfingkeys ở các host này, tự kèm mọi subdomain và mọi cổng. Không cần escape.
// prettier-ignore
const BLOCKLIST_HOSTS = [
  "youtube.com",
  // "localhost",
  // "127.0.0.1",
  // "ninjaverse.xyz",
];

// Phải là RegExp thật — Surfingkeys vá RegExp.prototype.toJSON để nó qua được
// sendMessage sang background. Neo `^` + lookahead cho mốc chỉ khớp phần host, không
// thì "ninjaverse.xyz" ăn cả example.com/?q=ninjaverse.xyz lẫn notninjaverse.xyz.
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

// Tab navigation — Ctrl-6 (built-in) nhảy về tab vừa dùng
map("J", "R");
map("K", "E");
map("H", "S");
map("L", "D");
map("[b", "B");
map("]b", "F");

// Close all tabs
map("gx", "gxx");

// Vẫn dùng được trong insert mode
unmap("<Ctrl-i>");

imap("jk", "<Esc>");

// map("p", "cc");  // mở URL trong clipboard ở tab mới
// imapkey("<Ctrl-u>", "Scroll up half page", () => Normal.scroll("pageUp"));
// imapkey("<Ctrl-d>", "Scroll down half page", () => Normal.scroll("pageDown"));

/***********************
SECTION: ALIASES
***********************/
["w", "s", "g", "e", "b", "y"].forEach((a) => removeSearchAlias(a));
unmap("on"); // nhường tiền tố cho "ont" bên dưới
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
// So khớp theo origin + path chứ không so chuỗi thô: nếu không, mốc
// "github.com/stars" khớp nhầm cả "github.com/starship/starship".
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

// [phím, url, tên hiển thị] — cột thứ ba chỉ khai khi tên suy ra từ URL khó đọc.
//
// Không phím nào được là tiền tố của phím khác: mapkey() sẽ im lặng bỏ phím dài,
// hoặc để phím ngắn xoá cả nhánh nếu đăng ký ngược lại — cảnh báo duy nhất ở mức
// `warn` mà logLevels mặc định chỉ bật `error`. Vì vậy mọi mốc github là "gh" +
// đúng một ký tự, trang chủ lấy dấu chấm (encodeKeystroke chỉ viết lại nhóm <...>
// nên dấu chấm là phím thường, chỉ khác là không chữ cái nào đụng vào được).
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

// Lối vào thứ hai cho cùng danh sách: gõ tên thay vì nhớ phím.
//
// Handler "UserURLs" luôn mở tab mới kể cả khi trang đã mở, và onEnter của nó không
// ghi đè được từ đây. Đường vòng: `openFocused` thấy uid bắt đầu bằng "T" thì gọi
// focusTab thay vì openLink — nên tra tab TRƯỚC khi mở omnibar rồi dán uid vào mục
// đang mở. (Chọn đúng trang đang xem thì không làm gì, khác toggleFocusUrl một chút.)
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
