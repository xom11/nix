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

// Tắt Surfingkeys ở các trang này. Mỗi dòng một host, tự kèm mọi subdomain và mọi
// cổng — thêm thì viết thêm dòng, tắt tạm thì comment dòng đó lại. Không cần escape
// gì, dấu chấm được escape sẵn ở dưới.
// prettier-ignore
const BLOCKLIST_HOSTS = [
  "youtube.com",
  // "localhost",
  // "127.0.0.1",
  // "ninjaverse.xyz",
];

// blocklistPattern phải là RegExp thật: content script gửi nó sang background qua
// sendMessage, sống sót được là nhờ Surfingkeys vá RegExp.prototype.toJSON thành
// {source, flags}, rồi background `new RegExp(source, flags)` và test với URL đầy đủ.
//
// Neo `^` ở đầu và lookahead ở cuối để một mốc chỉ khớp đúng phần host: nếu không,
// "ninjaverse.xyz" ăn cả https://example.com/?q=ninjaverse.xyz lẫn
// https://notninjaverse.xyz — đúng như regex cũ đang làm.
const blocklistHostAlt = BLOCKLIST_HOSTS.map((h) =>
  h.replace(/\./g, "\\."),
).join("|");

settings.blocklistPattern = new RegExp(
  `^https?://([^/]+\\.)?(${blocklistHostAlt})(:\\d+)?(?=[/?#]|$)`,
);

// Default search engine
settings.defaultSearchEngine = "gg";

// Không có `settings.autoFocusResults` — tên đó không tồn tại trong Surfingkeys
// 1.18.0 (grep cả bundle: 0 kết quả), nên dòng cũ đặt nó = false chỉ là code chết.
// Tên thật là `focusFirstCandidate`, mà mặc định đã là false rồi nên `t` vốn đã
// không auto-focus. Riêng omnibar <Space><Space> thì không tắt được bằng settings:
// handler UserURLs tự khai `focusFirstCandidate: true`, và điều kiện là
// `conf.focusFirstCandidate || handler.focusFirstCandidate` — OR nên handler thắng.

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
//
// Không phím nào được là tiền tố của phím khác: mapkey() thấy tiền tố đã có chủ
// thì bỏ luôn phím dài (`return void` trước mappings.add), còn đăng ký ngược lại
// thì phím ngắn xoá cả nhánh. Không có timeout để phân giải. Cảnh báo duy nhất là
// mức `warn`, mà logLevels mặc định chỉ bật `error` — nên hỏng là hỏng im lặng.
// Vì vậy mọi mốc github là "gh" + đúng một ký tự, trang chủ lấy dấu chấm. Dấu chấm
// đi thẳng qua encodeKeystroke (hàm đó chỉ viết lại các nhóm <...>) nên nó là một
// phím thường như mọi phím khác, chỉ khác là không chữ cái nào đụng vào được.
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
].map(([key, url, title]) => ({ key, url, title: title ?? titleFromUrl(url) }));

SITES.forEach(({ key, title, url }) =>
  mapkey(`<Space>${key}`, title, () => toggleFocusUrl(url)),
);

// Lối vào thứ hai cho cùng danh sách: gõ tên thay vì nhớ phím.
//
// Chọn một mục ở đây phải hành xử y như bấm phím tắt, mà omnibar không cho ghi đè
// onEnter: handler "UserURLs" đã đăng ký sẵn trong extension, `addHandler` chỉ gắn
// onEnter mặc định (`openFocused`) cho handler CHƯA có, và nó sống trong iframe
// pages/frontend.html — file này với không tới. Mặc định đó luôn ra tab mới, kể cả
// khi trang đã mở sẵn (background `openLink` không hề tra tab trùng).
//
// Đường vòng: `openFocused` đọc `li.uid`, thấy ký tự đầu là "T" thì gọi
// focusTab({windowId, tabId}) thay vì openLink; còn `createURLItem` gắn thẳng `uid`
// từ object ta truyền vào. Nên chỉ cần tra tab TRƯỚC khi mở omnibar rồi dán uid
// vào mục nào đang mở sẵn.
//
// Khác toggleFocusUrl đúng một điểm, cố ý: chọn đúng trang đang xem thì focusTab
// vào chính nó, tức không làm gì — thay vì quay về tab trước.
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
