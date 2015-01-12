"use strict"

class Atoms.Atom.Video extends Atoms.Atom.Li

  @extend: true

  @template: """
    <li data-video="{{id}}">
      <figure {{#viewed}}class="viewed"{{/viewed}}><span class="loading-animation"></span></figure>
      <div class="info">
        <div class="gloss"></div>
        <ul class="tags">
          {{#tags}}
          <a href="/tag/{{.}}" class="{{.}}">{{.}}</a>
          {{/tags}}
        </ul>
        {{#if.duration}}<small>{{duration}}m</small>{{/if.duration}}
      </div>
      <strong>{{title}}</strong>
      <small>{{when}}{{#if.views}} - {{views}} views{{/if.views}}</small>
    </li>
  """
