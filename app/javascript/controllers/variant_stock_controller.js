import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['newQuantity', 'threshold', 'operation', 'quantity']
  static values = { quantity: { type: Number, default: 0 }, operation: { type: String, default: 'add' } }

  recalculateStock() {
    if (!this.operationTarget.value)
      return

    let newQuantity
    if (this.quantityTarget.value)
      switch (this.operationTarget.value) {
        case 'add':
          newQuantity = parseInt(this.quantityValue) + parseInt(this.quantityTarget.value);
          break;
        case 'remove':
          newQuantity = parseInt(this.quantityValue) - parseInt(this.quantityTarget.value);
          break;
        case 'set':
          newQuantity = this.quantityTarget.value;
          break;
      }

    if (newQuantity || newQuantity === 0) {
      this.newQuantityTarget.innerHTML = newQuantity;
    } else {
      this.newQuantityTarget.innerHTML = this.quantityValue;
    }
  }

  toggleThreshholdInput() {
    this.thresholdTarget.classList.toggle('hidden');
  }
}