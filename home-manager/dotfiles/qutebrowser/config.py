# =======================
# Qutebrowser Config File
# =======================

config.load_autoconfig()
config.source('gruvbox.py')
config.set('content.javascript.clipboard', 'access')

# List of URLs to ABP-style adblocking rulesets.
c.content.blocking.adblock.lists = ['https://easylist.to/easylist/easylist.txt', 'https://easylist.to/easylist/easyprivacy.txt']

# Enable the ad/host blocker
c.content.blocking.enabled = True

# Block subdomains of blocked hosts.
c.content.blocking.hosts.block_subdomains = True

# List of URLs to host blocklists for the host blocker.
c.content.blocking.hosts.lists = ['https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts']

# Which method of blocking ads should be used.
c.content.blocking.method = 'auto'

# Allow pdf.js to view PDF files in the browser.
c.content.pdfjs = False

# Automatically enter insert mode if an editable element is focused
# after loading the page.
c.input.insert_mode.auto_load = False

# Leave insert mode when starting a new page load.
c.input.insert_mode.leave_on_load = True

# Languages to use for spell checking.
# c.spellcheck.languages = ['en-US', 'vi-VN']

c.editor.command = ["vim", "{}"]
c.fonts.web.size.default = 20
# c.zoom.default = '150%'


c.qt.force_software_rendering = "chromium"
# c.colors.webpage.darkmode.enabled = True
c.colors.webpage.preferred_color_scheme = 'dark'

c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 9, 'right': 9}
c.tabs.indicator.width = 0 # no tab indicators
c.tabs.width = '7%'

# Mininal decoration
c.window.hide_decoration = True
c.statusbar.show = 'in-mode'
c.tabs.show = 'never'

# Fonts
c.fonts.default_family = []
c.fonts.default_size = '25pt'
c.fonts.web.family.fixed = 'Inconsolata Nerd Font Mono'
c.fonts.web.family.sans_serif = 'Inconsolata Nerd Font Mono'
c.fonts.web.family.serif = 'Inconsolata Nerd Font Mono'
c.fonts.web.family.standard = 'Inconsolata Nerd Font Mono'

c.completion.web_history.max_items = -1
c.completion.open_categories = ['history', 'searchengines', 'quickmarks', 'bookmarks', 'filesystem']

c.url.start_pages = ['https://start.duckduckgo.com/']
c.url.default_page = 'https://start.duckduckgo.com/'
c.url.open_base_url = True;
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    'ddg': 'https://duckduckgo.com/?q={}',
    'pkgs': 'https://search.nixos.org/packages?channel=unstable&query={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}'
}

c.scrolling.smooth = True

# ========
# Bindings
# ========

# Change the default scrolling to scroll-px
config.bind('j', 'scroll-px 0 200')
config.bind('k', 'scroll-px 0 -200')

config.bind('gq', 'cmd-set-text -s :quickmark-load')
