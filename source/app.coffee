window.devcast = devcast = version: "0.13.6"

Atoms.$ ->
  Atoms.Url.options.absolute = true
  page = Atoms.$("body").attr "data-page"

  # -- Landing -----------------------------------------------------------------
  if page is "index"
    new Atoms.Organism.Header()
    new Atoms.Organism.App()
