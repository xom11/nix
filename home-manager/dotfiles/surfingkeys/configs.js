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
  vunmap
} = api;

// Scroll speed
settings.scrollStepSize = 200;

// Open Clipboard URL in new tab
map('P', 'cc');

// Tab navigation
map('J', 'R');
map('K', 'E');
map('H', 'S');
map('L', 'D');

// Close all tab
map('gx', 'gxx');
// Open a URL in current tab
map('<Space><Space>', 'go');

api.removeSearchAlias('w');
api.removeSearchAlias('s');
api.removeSearchAlias('g');
api.removeSearchAlias('e');
api.removeSearchAlias('b');
api.removeSearchAlias('y');
unmap('on');
api.addSearchAlias('gg', 'google', 'https://www.google.com/search?q=');
api.addSearchAlias('tt', 'taostats', 'https://taostats.io/subnets/%s');
api.addSearchAlias('gh', 'github', 'https://github.com/search?q=');
api.addSearchAlias('np', 'nixpkgs', 'https://search.nixos.org/packages?channel=unstable&query=%s');
api.addSearchAlias('nm', 'mynixos', 'https://mynixos.com/search?q=%s');
api.addSearchAlias('nv', 'nixvim', 'https://nix-community.github.io/nixvim/?search=%s');
api.addSearchAlias('yt', 'youtube', 'https://www.youtube.com/results?search_query=%s');

api.mapkey('ont', 'Open newtab', function () {
    api.tabOpenLink("www.google.com");
});

api.mapkey('ogH', 'Open Github', function () {
    window.location.replace("https://github.com/khanhkhanhlele?tab=repositories");
});
api.mapkey('ogS', 'Open github stars page ', function () {
    window.location.replace("https://github.com/khanhkhanhlele?tab=stars")
});

api.mapkey('ofB', 'Open facebook ', function () {
    window.location.replace("https://www.facebook.com/")
});
// Passthrough mode
api.map('<Ctrl-v>', '<Alt-i>');

api.mapkey('<Space>c', 'Go to the Code tab', function() {
    document.querySelector('a[data-hotkey="g c"]').click();
}, {
    domain: /github\.com/i
});
api.mapkey('<Space>i', 'Go to the Issues tab', function() {
    document.querySelector('a[id="issues-tab"]').click();
}, {
    domain: /github\.com/i
});
api.mapkey('<Space>d', 'Go to the Discussions tab', function() {
    document.querySelector('a[id="discussions-tab"]').click();
}, {
    domain: /github\.com/i
});
api.mapkey('<Space>w', 'Go to the Wiki tab', function() {
    document.querySelector('a[id="wiki-tab"]').click();
}, {
    domain: /github\.com/i
});
api.mapkey('<Space>p', 'Go to the Pull requests tab', function() {
    document.querySelector('a[id="pull-requests-tab"]').click();
}, {
    domain: /github\.com/i
});

api.mapkey('<space>y', '#7 git clone', function () {
    api.Clipboard.write('git clone ' + window.location.href + '.git');
}, {
    domain: /github\.com/i
});

settings.defaultLLMProvider = "gemini";
settings.llm = {
    gemini: {
        apiKey: '***********************************',
    },
    deepseek: {
        apiKey: '***********************************',
        model: 'deepseek-chat',
    },
};
