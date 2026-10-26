import { Controller } from "@hotwired/stimulus"

// Removes its element from the page, used for closable flash messages.
export default class extends Controller {
  close() {
    this.element.remove()
  }
}
