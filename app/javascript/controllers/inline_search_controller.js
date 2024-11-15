import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelector('input').addEventListener('input', this.debouncedSubmit.bind(this))
  }

  disconnect() {
    this.element.querySelector('input').removeEventListener('input', this.debouncedSubmit)
  }

  debouncedSubmit() {
    clearTimeout(this.submit)

    this.submit = setTimeout(() => {
      this.element.requestSubmit();
    }, 500);
  }
}