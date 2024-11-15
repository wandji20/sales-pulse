import { Controller } from "@hotwired/stimulus"
import useTriggerOpenAndClose from "mixins/useTriggerOpenAndClose";

export default class extends Controller {
  static targets = ['dropdownToggle', 'modalTrigger', 'sidebarToggle']

  connect() {
    useTriggerOpenAndClose(this);
    // Attach event handler for closing opened dropdowns, sidebars, and modals
    document.addEventListener('click', this.#handleOpenedComponents.bind(this));

    // Add escape key handler to close modal
    document.addEventListener('keydown', this.#closeModal.bind(this));

    // Attach event handler for opening modals
    document.addEventListener('click', this.#handleModalTrigger.bind(this))

    // Attach event handler for toggling dropdowns
    document.addEventListener('click', this.#handleDropdownToggle.bind(this))

    // Attach event handler for toggling sidebar
    this.sidebarToggleTargets.forEach((sidebarToggle) => {
      sidebarToggle.addEventListener('click', this.#toggleSidebar);
    });
  }

  disconnect() {
    // Remove event handler for closing opened dropdowns, sidebars, and modals
    document.removeEventListener('click', this.#handleOpenedComponents.bind(this));

    // Remove escape key handler to close modal
    document.removeEventListener('keydown', this.#closeModal.bind(this));

    // Remove event handler for opening modals
    document.removeEventListener('click', this.#handleModalTrigger.bind(this));

    // Remove event handler for toggling dropdowns
    document.removeEventListener('click', this.#handleDropdownToggle.bind(this))

    // Remove event handler for toggling sidebar
    this.sidebarToggleTargets.forEach((sidebarToggle) => {
      sidebarToggle.removeEventListener('click', this.#toggleSidebar);
    });
  }

  #handleModalTrigger(event) {
    const modalTrigger = event.target.closest("[data-components-target='modalTrigger']")

    if (modalTrigger)
      this.#openModal.bind(this)(modalTrigger)
  }

  #handleDropdownToggle(event) {
    const dropdownToggle = event.target.closest('.dropdown')

    if(dropdownToggle)
      dropdownToggle.querySelector('.dropdown-menu').classList.toggle('hidden')
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

  #toggleSidebar() {
    document.querySelector('#mobile-menu').classList.toggle('hidden');
  }

  #handleOpenedComponents(event) {
    this.#closeOffCanvas(event);

    this.#closeDropdowns(event);

    this.#closeModals(event);
  }

  #closeOffCanvas(event) {
    // Do nothing when navbar toggle is clicked
    if (event.target.closest("button[data-components-target='sidebarToggle']")) return;

    // Do nothing when clicked within sidebar
    if (event.target.closest('#off-canvas-content')) return

    document.querySelector('#mobile-menu').classList.add('hidden');
  }

  #closeDropdowns(event) {
    this.dropdownToggleTargets.forEach((dropdownToggle) => {
      // close all dropdowns except targeted dropdown
      if(!event.target.closest('.dropdown-toggle'))
        dropdownToggle.closest('.dropdown').querySelector('.dropdown-menu').classList.add('hidden');
    });
  }

  #closeModals(event) {
    // Do nothing when modal trigger is clicked
    if (event.target.closest("[data-components-target='modalTrigger']")) return;
    // Do nothing when clicked within modal content
    if(event.target.closest('.modal-content')) return;

    this.triggerClose('modal:close', document)
  }
}
