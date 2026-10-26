import { Controller } from "@hotwired/stimulus"

// Reveals the RubyUI alert (rendered hidden) when the submit button is clicked.
export default class extends Controller {
  static targets = ["alert"]

  notify() {
    this.alertTargets.forEach((alert) => alert.classList.remove("hidden"))
  }
}
