import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")

    const expanded =
      !this.panelTarget.classList.contains("hidden")

    this.buttonTarget.setAttribute(
      "aria-expanded",
      expanded
    )
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.panelTarget.classList.add("hidden")
      this.buttonTarget.setAttribute(
        "aria-expanded",
        "false"
      )
    }
  }

  connect() {
    this._outsideClick = this.close.bind(this)
    document.addEventListener("click", this._outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClick)
  }
}
