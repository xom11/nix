config.load_autoconfig()
c.window.hide_decoration = True
c.tabs.show = 'never'
c.fonts.default_family = "Fira Code"
c.url.start_pages = ['https://start.duckduckgo.com']
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'gg': 'https://google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}'
}