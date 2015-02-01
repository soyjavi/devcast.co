window.devcast = devcast = version: "0.13.6"

Atoms.$ ->
  Atoms.Url.options.absolute = true

  page = Atoms.$("body").attr "data-page"

  # -- Landing -----------------------------------------------------------------
  if page is "index"
    new Atoms.Organism.App()
  # -- Video -------------------------------------------------------------------
  else if page is "video"
    console.log "video"
