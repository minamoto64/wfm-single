import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const icon = button.querySelector(".toggle-icon")
    const parentRow = button.closest("tr")

    // 親行の直後に連続する関連行だけを集める
    const rows = []
    let sibling = parentRow.nextElementSibling
    while (sibling && sibling.classList.contains("related-list-row")) {
      rows.push(sibling)
      sibling = sibling.nextElementSibling
    }

    const shouldShow = rows.some((row) => row.classList.contains("hidden"))

    rows.forEach((row) => {
      row.classList.toggle("hidden", !shouldShow)
      row.classList.toggle("bg-gray-100", shouldShow)
      row.classList.toggle("border-l-4", shouldShow)
      row.classList.toggle("border-gray-400", shouldShow)
    })

    parentRow.classList.toggle("bg-gray-100", shouldShow)
    parentRow.classList.toggle("border-l-4", shouldShow)
    parentRow.classList.toggle("border-gray-400", shouldShow)

    button.setAttribute("aria-expanded", shouldShow)
    if (icon) icon.textContent = shouldShow ? "▲" : "▼"
  }
}
