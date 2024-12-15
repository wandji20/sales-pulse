import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['days', 'months', 'years', 'period']

  toggleFilterOption(e) {
    this.periodTargets.forEach(period => {
      if (period.dataset.value === e.target.value) {
        period.classList.remove('hidden');
        // Disable hidden fields to avoid sending params in request
        period.querySelectorAll('input').forEach(input => input.disabled = false)
      } else { 
        period.classList.add('hidden');
        period.querySelectorAll('input').forEach(input => input.disabled = true)
      }
    });
  }
}