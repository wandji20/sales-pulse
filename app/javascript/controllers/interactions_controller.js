import { Controller } from "@hotwired/stimulus"
import useTriggerOpenAndClose from "mixins/useTriggerOpenAndClose";

export default class extends Controller {
  static targets = ['dropdownToggle', 'modalTrigger', 'sidebarToggle']

  connect() {
    useTriggerOpenAndClose(this);
    // Add escape key handler to close modal
    document.addEventListener('keydown', this.#closeModal.bind(this));

    // Attach event handler for modals
    document.addEventListener('click', this.#handleClick.bind(this))
  }

  disconnect() {
    // Remove escape key handler to close modal
    document.removeEventListener('keydown', this.#closeModal.bind(this));

    // Remove event handler for modals
    document.removeEventListener('click', this.#handleClick.bind(this));
  }

  #handleClick(event) {
    const modalTrigger = event.target.closest("[data-interactions-target='modalTrigger']")

    if (modalTrigger) {
      this.#openModal.bind(this)(modalTrigger)
    } else {
      this.#closeAllModals(event);
    }
  }

  #openModal(triggerElement) {
    const targetElement = document.getElementById(triggerElement.dataset.modalTarget);

    this.triggerOpen('modal:open', targetElement, triggerElement);
  }

  #closeModal(event) {
    if (event.key === "Escape") {
      this.triggerClose('modal:close', document)
    }
  }

  #closeAllModals(event) {
    // Do nothing when modal trigger is clicked
    if (event.target.closest("[data-interactions-target='modalTrigger']")) return;
    // Do nothing when clicked within modal content
    if(event.target.closest('.modal-content')) return;

    this.triggerClose('modal:close', document)
  }
}
