config.load_autoconfig()
config.source('gruvbox.py')
config.set('content.javascript.clipboard', 'access')

c.content.blocking.method = "adblock"
c.editor.command = ["vim", "{}"]
c.fonts.web.size.default = 20

config.bind('gq', 'cmd-set-text -s :quickmark-load')


c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 9, 'right': 9}
c.tabs.indicator.width = 0 # no tab indicators
c.tabs.width = '7%'

# Mininal decoration
c.window.hide_decoration = True
c.statusbar.show = 'in-mode'
c.tabs.show = 'never'

# Fonts
c.fonts.default_family = []
c.fonts.default_size = '15pt'
c.fonts.web.family.fixed = 'Inconsolata Nerd Font Mono'
c.fonts.web.family.sans_serif = 'Inconsolata Nerd Font Mono'
c.fonts.web.family.serif = 'Inconsolata Nerd Font Mono'
c.fonts.web.family.standard = 'Inconsolata Nerd Font Mono'

c.completion.web_history.max_items = -1
c.completion.open_categories = ['history', 'searchengines', 'quickmarks', 'bookmarks', 'filesystem']

c.url.start_pages = ['https://start.duckduckgo.com/']
c.url.default_page = "https://start.duckduckgo.com/"
c.url.open_base_url = True;
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    'ddg': 'https://duckduckgo.com/?q={}',
    'pkgs': 'https://search.nixos.org/packages?channel=unstable&query={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}'
}

c.scrolling.smooth = True
