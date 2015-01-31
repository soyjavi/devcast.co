"use strict"

class Atoms.Atom.Video extends Atoms.Atom.Li

  @extend: true

  @template: """
    <li data-video="{{id}}" class="{{style}}">
      <figure><span class="loading-animation"></span></figure>
      <div class="general">
        {{#if.duration}}<small>{{duration}}m</small>{{/if.duration}}
        <h2>{{title}}</h2>
      </div>
      <div class="info">
        <strong>{{description}}</strong>
        <nav>
          {{#tags}}<a href="/tag/{{.}}" class="{{.}}">{{.}}</a>{{/tags}}
        </nav>
        <small>{{when}}{{#if.views}} - {{views}} views{{/if.views}}</small>
      </div>
    </li>
  """
