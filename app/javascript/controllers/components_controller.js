import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['flyout', 'modal', 'dropdown']

  connect() {
    document.addEventListener('click', this.#handleNavAndDropdowns.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.#handleNavAndDropdowns);
  }

  toggleNavMenu() {
    document.querySelector('#mobile-menu').classList.toggle('hidden');
  }

  toggleDropdown(event) {
    event.target.closest('.dropdown').querySelector('.dropdown-menu').classList.toggle('hidden');
  }

  #handleNavAndDropdowns(event) {
    // close opened sidebar
    if (!event.target.closest('#off-canvas-content'))
      this.#closeOffCanvas(event);
  
    this.#closeDropdowns(event);
  }

  #closeOffCanvas(event) {
    // Do nothing when navbar toggle is clicked
    if (event.target.closest(".navbar-toggle")) return;

    document.querySelector('#mobile-menu').classList.add('hidden');
  }

  #closeDropdowns(event) {
    this.dropdownTargets.forEach((dropdown) => {
      // clse all dropdowns except targeted dropdown
      if(!event.target.closest('.dropdown-toggle'))
        dropdown.querySelector('.dropdown-menu').classList.add('hidden')
    });
  }
}
