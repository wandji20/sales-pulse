import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const submitButton = this.element.querySelector('input[name="commit"')
    this.element.querySelectorAll('input').forEach(input => {
      if (input.id) {
        input.addEventListener('input', () => {
          submitButton.disabled = false;
        });
      }
    });

    this.element.querySelectorAll('select').forEach(select => {
      if (select.id) {
        select.addEventListener('change', () => {
          submitButton.disabled = false;
        });
      }
    });
  }
}