import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['toggler', 'sidebar']

  connect() {
    // Attach event handler for closing sidebar
    document.addEventListener('click', this.handleClick.bind(this));
  }

  disconnect() {
    // Remove event handler for closing sidebar
    document.removeEventListener('click', this.handleClick.bind(this));
  }

  toggle() {
    if (this.sidebarTarget.classList.contains('show')) {
      this.#close();
    } else {
      this.#open();
    }
  }

  handleClick(event) {
    // Do nothing when navbar toggle is clicked
    if (event.target.closest("button[data-sidebar-target='toggler']")) return;

    // Do nothing when clicked within sidebar
    if (event.target.closest('.off-canvas-content')) return;

    this.#close();
  }

  #open() {
    this.sidebarTarget.classList.remove('invisible');
    this.sidebarTarget.classList.remove('hide');
    this.sidebarTarget.classList.add('show');
  }

  #close() {
    this.sidebarTarget.classList.remove('show');
    this.sidebarTarget.classList.add('hide');
    //  delay to finish aimation
    setTimeout(() => {
      this.sidebarTarget.classList.add('invisible');
    }, 300);
  }
}
