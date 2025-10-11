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

// Open Clipboard URL in new tab
map('P', 'cc');

// Tab navigation
map('J', 'R');
map('K', 'E');
map('H', 'S');
map('L', 'D');

api.removeSearchAlias('w');
api.removeSearchAlias('s');
api.removeSearchAlias('g');
api.removeSearchAlias('e');
api.removeSearchAlias('b');
api.addSearchAlias('G', 'google', 'https://www.google.com/search?q=');
api.addSearchAlias('gg', 'google', 'https://www.google.com/search?q=');
api.addSearchAlias('tt', 'taostats', 'https://taostats.io/subnets/%s');
api.addSearchAlias('gh', 'github', 'https://github.com/search?q=');
api.addSearchAlias('gs', 'githubStars', 'https://github.com/khanhkhanhlele?page=1&q=face&tab=stars&utf8=%E2%9C%93&utf8=%E2%9C%93&q=');

// map(<Space><Space>, 'ogg');

api.mapkey('on', '#3Open newtab', function () {
    api.tabOpenLink("www.google.com"); // TODO: addded api, but not work
});

api.mapkey('oGi', '#7 open gist', function () {
    window.location.replace("https://gist.github.com/")
});

// Passthrough mode
api.map('<Ctrl-v>', '<Alt-i>');

api.mapkey('<Space>c', 'Go to the Code tab', function() {
    document.querySelector('a[data-hotkey="g c"]').click();
}, {
    domain: /github\.com/i
});
api.mapkey('<Space>i', 'Go to the Code tab', function() {
    document.querySelector('a[id="issues-tab"]').click();
}, {
    domain: /github\.com/i
});

api.mapkey('<space>y', '#7 git clone', function () {
    api.Clipboard.write('git clone ' + window.location.href + '.git');
}, {
    domain: /github\.com/i
});

