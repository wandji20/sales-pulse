import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Ensure modalTarget data attribute is unique
  // This will trigger a modal:open event which is listened in the modal controller
  fireModalEvent(event) {
    const modal = document.querySelector(event.currentTarget.dataset.target);

    if (!modal) return;

    modal.dispatchEvent(new CustomEvent('modal:open', { detail: { trigger: event.currentTarget } }));
  }
}