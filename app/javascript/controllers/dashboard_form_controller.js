import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['custom']

  applyPeriod(e) {
    if(e.target.value === 'custom') {
      this.customTarget.classList.remove("hidden");
      this.customTarget.querySelector("input").disabled = false;
    } else {
      this.customTarget.classList.add("hidden");
      this.customTarget.querySelector("input").disabled = true;

      this.search();
    }
  }

  search() {
    this.element.requestSubmit();
  }
}