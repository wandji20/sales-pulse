import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['backdrop']

  connect() {
    this.element.addEventListener('modal:open', this.#openModal.bind(this));
    document.addEventListener('modal:close', this.#closeModal.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('modal:open', this.#openModal.bind(this));
    document.removeEventListener('modal:close', this.#closeModal.bind(this));
  }

  #openModal(event) {
    this.element.classList.remove('hidden');
    document.querySelector('body').classList.add('overflow-y-hidden');
  }

  #closeModal() {
    this.element.classList.add('hidden');
    document.querySelector('body').classList.remove('overflow-y-hidden');
  }
}
