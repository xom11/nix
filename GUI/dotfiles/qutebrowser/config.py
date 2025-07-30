config.load_autoconfig()
config.source('gruvbox.py')

c.content.blocking.method = "adblock"
c.editor.command = ["vim", "{}"]
c.fonts.web.size.default = 20

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

c.completion.open_categories = ['searchengines', 'quickmarks', 'bookmarks', 'history', 'filesystem']
c.url.start_pages = ['https://start.duckduckgo.com']
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'gg': 'https://google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}'
}

c.scrolling.smooth = True