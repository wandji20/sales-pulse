import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "dropdownToggle"]

  connect() {
    document.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  toggle() {
    this.element.querySelector('.dropdown-menu').classList.toggle('hidden')
  }

  // open() {
  //   this.element.querySelector('.dropdown-menu').classList.remove('hidden')
  // }

  close() {
    this.element.querySelector('.dropdown-menu').classList.add('hidden');
  }

  handleClickOutside(event) {
    this.dropdownTargets.forEach((dropdown) => {
      // Do nothing when when clicked in dropdown
      if (dropdown.contains(event.target)) return;

      // close any other dropdown
      dropdown.querySelector('.dropdown-menu').classList.add('hidden')
    })
  }
}