import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['flyout', 'modal']

  connect() {
    document.addEventListener('click', this.#handleNavAndDropdowns.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.#handleNavAndDropdowns);
  }

  toggleNavMenu() {
    document.querySelector('#mobile-menu').classList.toggle('hidden');
  }

  #handleNavAndDropdowns(event) {
    // close opened sidebar
    if (!event.target.closest('#off-canvas-content'))
      this.#closeOffCanvas(event);
  
    this.#openDropdown(event);
  }

  #closeOffCanvas(event) {
    // Do nothing when navbar toggle is clicked
    if (event.target.closest(".navbar-toggle")) return;

    document.querySelector('#mobile-menu').classList.add('hidden');
  }

  #openDropdown(event = null) {
    const dropdown = event.target.closest('.dropdown');
    // Close all dropdowns and toggle hidden class for targeted dropdown
    document.querySelectorAll('.dropdown .dropdown-menu').forEach((menu) => {
      if (!dropdown)
        menu.classList.add('hidden');
      else
        dropdown.querySelector('.dropdown-menu').classList.toggle('hidden');
    });
  }
}
