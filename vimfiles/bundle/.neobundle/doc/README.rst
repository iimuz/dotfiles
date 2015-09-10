========================
 Sphinx Bootstrap Theme
========================

This repository integrates the Twitter Bootstrap_ CSS / JavaScript framework
as a Sphinx_ theme_. A live demo_ is available to preview the theme.

.. _Bootstrap: http://twitter.github.com/bootstrap/
.. _Sphinx: http://sphinx.pocoo.org/
.. _theme: http://sphinx.pocoo.org/theming.html
.. _demo: http://ervandew.github.com/sphinx-bootstrap-theme

Installation
============

To install the theme, download the theme directory and update your
configuration

1. Create a "_themes" directory in your project source root.
2. Get the "bootstrap" themes by cloning this repo or download the full repo
   source and move the "bootstrap" directory to "_themes".
3. Edit your configuration file to point to the bootstrap theme::

      # Activate the theme.
      sys.path.append(os.path.abspath('_themes'))
      html_theme_path = ['_themes']
      html_theme = 'bootstrap'
      html_translator_class = 'bootstrap.HTMLTranslator'

      # (Optional) Use a shorter name to conserve nav. bar space.
      html_short_title = "Demo"

      # (Optional) Logo. Should be exactly 32x32 px to fit the nav. bar.
      # Path should be relative to the html_static_path setting (e.g.,
      # "_static") in source.
      html_logo = "my_logo.png"

Theme Notes
===========

Sphinx
------

The theme places the global TOC, navigation (prev, next) and
source links all in the top Bootstrap navigation bar, along with the Sphinx
search bar on the left side.

The location of the page local TOC is by default placed in a 'subnav' located
just below the page heading. If there are too many items to fit within the
width of the subnav, then the subnav will have a scroll on hover region on
either side of the subnav. If you would like to have your page local TOC placed
elsewhere, you can set ``page_toc_position`` in your ``html_theme_options`` in
your sphinx ``config.py`` as described in the configuration section below.

The global (site-wide) table of contents is the "Site" navigation dropdown,
which is a multi-level deep rendering of the ``toctree`` for the entire site.

The local (page-level) table of contents is the "Page" navigation dropdown,
which is a multi-level rendering of the current page's ``toc``.

Configuration
-------------

Sphinx allows you to specify theme specific options in your ``config.py`` by
adding them to the ``html_theme_options`` variable:

.. code:: python

  html_theme_options = {
    'page_toc_position': 'sidebar-left',
  }

This theme supports the following options:

**global_toc_maxdepth** (Default: 1): Set the max number of levels to render
for the global table of contents.

**global_toc_includehidden** (Default: True): When True, include hidden toc
entries (those using the ``:hidden:`` directive) in the global table of
contents.

**global_toc_name** (Default: Site): Set the text used for the global toc
found in the header. Note: this value is also used as the key for translations
of the text.

**page_toc_position** (Default: subnav): Specifies where the page local TOC
will be rendered. Supported values include:

- **nav**: In the main navigation header next to the global site TOC.
- **subnav**: In a subnav bar.
- **sidebar-left**: In a sidebar to the left of the main page content.
- **sidebar-right**: In a sidebar to the right of the main page content.

**page_toc_maxdepth** (Default: -1): Allows you to limit the page local TOC
to the specified depth. When using the 'subnav' position the depth is
currently set to 1.

**sourcelink_position** (Default: nav): Specifies the location where the
"Source" link, if enabled in your config.py, will be displayed. Supported
values include:

- **nav**: In the main navigation header after the other navigation links.
- **footer**: In the page footer alongside the "Back To Top" link.

**show_bootstrap** (Default: False): If true, a link to this theme will be
place alongside the "Created using Sphinx" text in the footer.


Bootstrap
---------

The theme uses Twitter Bootstrap v2.1.0. You can override any static JS/CSS
files by dropping different versions in your Sphinx "_static" directory.


Licenses
========

Sphinx Bootstrap Theme is licensed under the MIT_ license.

Twitter Bootstrap is licensed under the Apache_ license.

.. _MIT: https://github.com/ervandew/sphinx-bootstrap-theme/blob/master/LICENSE.txt
.. _Apache: https://github.com/twitter/bootstrap/blob/master/LICENSE
