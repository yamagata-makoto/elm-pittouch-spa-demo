# patch for Elm
Object.define-property XMLHttpRequest.prototype, 'response',
  get: -> @responseText

flags = null

{ Elm } = require './elm'

app = Elm.Main.init flags: flags

console.log (history.push-state {}, "", "/foo")
console.log (location.href)
