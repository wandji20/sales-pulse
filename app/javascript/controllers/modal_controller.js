import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['content']

  connect() {
    this.element.addEventListener('modal:open', this.#openModal.bind(this));
    this.element.addEventListener('turbo:submit-end', this.#closeFormModal.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('modal:open', this.#openModal.bind(this));
    this.element.removeEventListener('turbo:submit-end', this.#closeFormModal.bind(this));
  }

  async #openModal(event) {
    const { trigger } = event.detail;
    const { url } = trigger.dataset;

    if (url) {
      this.clearContentOnClose = true;
      const response = await fetch(url, { headers: { "Accept": "application/json" } });
      const data = await response.json();
      this.contentTarget.innerHTML = data.html;
    }
    
    this.element.classList.remove('invisible');
    this.element.classList.remove('hide');
    this.element.classList.add('show');

    // Manually focus modal to enable keyboard interactions
    this.#focusContent()
    // remove document overflow
    document.querySelector('body').classList.add('overflow-y-hidden');
  }

  closeModal() {
    this.element.classList.remove('show');
    this.element.classList.add('hide');
    //  delay to finish animation
    setTimeout(() => {
      this.element.classList.add('invisible');

      document.querySelector('body').classList.remove('overflow-y-hidden');
  
      if (this.clearContentOnClose) {
        this.contentTarget.innerHTML = '';
      }
    }, 200);

  }

  #closeFormModal(event) {
    if (event.detail.success) {
      this.closeModal();
    }
  }

  #focusContent() {
    setTimeout(() => {
      const focusableEle = this.element.querySelector("[autofocus]");
      // focus first input fied with autofucus attribute true of focus modal
      if (focusableEle) {
        focusableEle.focus();

        return
      }
  
      this.element.focus()
    }, 100);
  }
}
