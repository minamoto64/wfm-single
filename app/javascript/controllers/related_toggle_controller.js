import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "icon", "button", "card"]

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const isHidden = this.listTarget.classList.toggle("hidden")
    const shouldShow = !isHidden

    this.cardTargets.forEach((card) => {
      card.classList.toggle("bg-white", !shouldShow)
      card.classList.toggle("bg-gray-100", shouldShow)
      card.classList.toggle("border-l-4", shouldShow)
      card.classList.toggle("border-gray-400", shouldShow)
    })

    this.buttonTarget.setAttribute("aria-expanded", shouldShow.toString())
    this.iconTarget.textContent = shouldShow ? "▲" : "▼"
  }
}
