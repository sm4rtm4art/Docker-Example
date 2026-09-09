"""Build the English course directly from its Markdown source tree."""
project = "Docker Learning Path"
author = "Docker Learning Path contributors"
language = "en"
extensions = ["myst_parser"]
source_suffix = {".md": "markdown"}
root_doc = "index"
exclude_patterns = ["**/.venv/**", "**/target/**", "**/__pycache__/**"]
myst_heading_anchors = 3
html_theme = "furo"
html_title = "Docker Learning Path"
html_show_sourcelink = False
html_theme_options = {"navigation_with_keys": True}
