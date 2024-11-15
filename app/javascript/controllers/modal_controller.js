import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['backdrop', 'content']
  static values = { lazyLoadContent: { type: Boolean, default: false }}

  connect() {
    this.element.addEventListener('modal:open', this.#openModal.bind(this));
    document.addEventListener('modal:close', this.closeModal.bind(this));
    document.addEventListener('turbo:submit-end', this.#closeFormModal.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('modal:open', this.#openModal.bind(this));
    document.removeEventListener('modal:close', this.closeModal.bind(this));
  }

  async #openModal(event) {
    this.element.classList.remove('hidden');
    document.querySelector('body').classList.add('overflow-y-hidden');

    if (this.lazyLoadContentValue) {
      const url = event.detail.triggerElement?.dataset?.url
      if (!url) return;

      const response = await fetch(url, { headers: { "Accept": "application/json" } });
      const data = await response.json();
      this.contentTarget.innerHTML = data.html;
    }
  }

  closeModal() {
    this.element.classList.add('hidden');
    this.contentTarget.innerHTML = '';
    document.querySelector('body').classList.remove('overflow-y-hidden');
  }

  #closeFormModal(event) {
    if (event.detail.success) {
      this.closeModal();
    }
  }
}
