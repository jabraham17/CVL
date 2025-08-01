import os

# use pip vendor TOML if no system TOML is available (Python 3.10 or less)
try:
    import tomllib
except ModuleNotFoundError:
    import pip._vendor.tomli as tomllib

on_rtd = os.environ.get("READTHEDOCS", None) == "True"

needs_sphinx = "1.0"

extensions = [
    "sphinx.ext.todo",
    "sphinxcontrib.chapeldomain",
    "sphinx.ext.mathjax",
]

source_suffix = ".rst"
root_doc = "index"


def get_metadata():
    with open(
        os.path.join(os.path.dirname(__file__), "..", "Mason.toml"), "rb"
    ) as f:
        brick = tomllib.load(f)["brick"]
        metadata = {
            "name": brick["name"],
            "version": brick["version"],
            "author": brick.get("author", ""),
            "license": brick.get("license", ""),
            "copyright": brick.get("copyright", ""),
        }
    return metadata


metadata = get_metadata()

project = metadata["name"]
author_text = metadata["author"]
copyright = metadata["copyright"]

# The short X.Y version.
version = metadata["version"].split("-")[0]
# The full version, including alpha/beta/rc tags.
release = metadata["version"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = []

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = "sphinx"

if not on_rtd:
    import sphinx_rtd_theme

    html_theme = "sphinx_rtd_theme"
    html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]

    html_theme_options = {
        "sticky_navigation": True,
    }
