"use strict"

var zen = require('zenserver').start();

var youtube = require('./api/crawler/youtube.coffee')
new youtube({
  name    : "youtube.com",
  schedule: "5 * * * *",
  timezone: "Europe/Amsterdam",
});

var devcasts = require('./api/crawler/devcasts.coffee')
new devcasts({
  name    : "devcast.io",
  schedule: "10 0 * * *",
  timezone: "Europe/Amsterdam",
});

var tagtree = require('./api/crawler/tagtree.coffee')
new tagtree({
  name    : "tagtree.io",
  schedule: "20 0 * * *",
  timezone: "Europe/Amsterdam",
});

var vimeo = require('./api/crawler/vimeo.coffee')
new vimeo({
  name    : "vimeo.com",
  schedule:  "30 0 * * *",
  timezone: "Europe/Amsterdam",
});

var ustream = require('./api/crawler/ustream.coffee')
new ustream({
  name    : "ustream.com",
  schedule: "40 0 * * *",
  timezone: "Europe/Amsterdam",
});
