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
        {{#duration}}
        <small>{{duration}}m</small>
        {{/duration}}
      </div>
      <strong>{{title}}</strong>
      <span>by <a href="/author/{{author.name}}">{{author.name}}</a></span>
      <small>{{when}}{{#views}} - {{views}} views{{/views}}</small>
    </li>
  """
