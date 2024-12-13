import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { searchUrl: String, selected: { type: Array, default: [] }, multiple: false }
  static targets = ["input", "label", "options", "option", "newOptionGroup"]

  connect() {
    this.#setDisplayValue();
    document.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  search() {
    if (!this.searchUrlValue) return;
    clearTimeout(this.debouncedSearch);

    this.debouncedSearch = setTimeout(async () => {
      const response = await fetch(`${this.searchUrlValue}?search=${this.inputTarget.value}`, { headers: { "Accept": "text/vnd.turbo-stream.html" } });
      const streamContent = await response.text();
      Turbo.renderStreamMessage(streamContent);
    }, 500);
  }

  toggleOption(e) {
    const value = e.currentTarget.dataset.value;
    this.#updateValues(value);
  }

  closeList(event = null) {
    // Prevent closing modal and hide options
    if (event)
      event.stopPropagation();
    this.optionsTarget.classList.add('hidden');
  }

  toggleDropdown() {
    this.inputTarget.focus();
    if (this.optionsTarget.dataset.show === 'true') 
      this.optionsTarget.classList.toggle('hidden');
  }

  handleClickOutside(event) {
    // Close list when clicked on dropdown label or outside dropdown
    if (!this.element.contains(event.target) || this.labelTarget.contains(event.target))
      this.closeList(event);
  }

  toggleNewOptionGroup() {
    if (this.newOptionGroupTarget.classList.contains('hidden')) {
      this.newOptionGroupTarget.querySelector("input[name='add_new_option']").value = 'true';
      this.newOptionGroupTarget.classList.remove('hidden');
    } else {
      this.newOptionGroupTarget.querySelector("input[name='add_new_option']").value = 'false';
      this.newOptionGroupTarget.classList.add('hidden');
    }
  }

  #updateValues(value) {
    let selected = this.selectedValue

    if (value === 'all') {
      selected = [];
      if (!this.selectedValue.includes('all')) {
        this.optionTargets.forEach(option => {
          selected.push(option.dataset.value);
        })
        selected.push('all');
      }
    } else if (!this.multipleValue) {
      selected = [value];
    } else {
      if (selected.includes(value)) {
        selected = selected.filter(val => val !== 'all' && val !== value);
      } else {
        selected.push(value);
      }
    }

    this.selectedValue = selected
    this.#setDisplayValue();

    this.#markSelected();
  }

  #markSelected() {
    this.optionTargets.forEach((option) => {
      const checkbox = option.querySelector('input[type="checkbox"]');
      const optionValue = option.dataset.value;
      if (this.selectedValue.includes(optionValue)) {
        if (checkbox) checkbox.checked = true;
      
        option.classList.add('selected');
      } else {
        if (checkbox) checkbox.checked = false;

        option.classList.remove('selected');
      }
    })
  }

  #setDisplayValue() {
    if (this.selectedValue.length === 0) {
      this.inputTarget.value = '';
      return
    }
  
    let label = this.optionsTarget.querySelector(`li[data-value="${this.selectedValue[0]}"]`)
                                  .dataset.label;

    if (this.multipleValue) {
      const total = this.selectedValue.filter(val => val !== 'all').length;
      if (total > 1) label = `${total} selected`;
    }
    this.inputTarget.value = label;
  }
}