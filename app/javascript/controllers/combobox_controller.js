import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { searchUrl: String, selected: { type: Array, default: [] }, multiple: false }
  static targets = ["input", "hiddenInput", "label", "options", "option", "newOptionGroup"]

  connect() {
    this.#updateSeachValue();
    document.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  search() {
    if (!this.searchUrlValue) return;
    clearTimeout(this.debouncedSearch);

    // Reset hiddenField value
    this.hiddenInputTarget.value = '';
  
    this.debouncedSearch = setTimeout(async () => {
      const response = await fetch(`${this.searchUrlValue}?search=${this.inputTarget.value}`, { headers: { "Accept": "text/vnd.turbo-stream.html" } });
      const streamContent = await response.text();
      Turbo.renderStreamMessage(streamContent);
    }, 500);
  }

  selectOption(event) {
    let values = this.selectedValue
    if (this.multipleValue === false) {
      values = [event.currentTarget.dataset.value]
    }else if (values.includes(event.currentTarget.dataset.value)) {
      values = values.filter(val => val !== event.currentTarget.dataset.value);
    } else {
      values.push(event.currentTarget.dataset.value);
    }

    this.selectedValue = values;
  
    this.#updateSeachValue();
    this.#updateSelectedOptions();
  }

  closeList(event = null) {
    // Prevent closing modal and hide options
    if (event)
      event.stopPropagation();
    this.optionsTarget.classList.add('hidden');
  }

  toggleList() {
    this.inputTarget.focus();
    if (this.optionsTarget.dataset.show === 'true') 
      this.optionsTarget.classList.toggle('hidden');
  }

  handleClickOutside(event) {
    // Close list when clicked on combobox label or outside combobox
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

  #updateSelectedOptions() {
    this.optionTargets.forEach((listItem) => {

      // Mark selected option
      if (this.selectedValue.includes(listItem.dataset.value)) {
        listItem.classList.add('selected');
      } else {
        listItem.classList.remove('selected');
      }

      // set value for hidden input
      this.#updateHiddenInputvalue();

      if (listItem.dataset.value === 'new') {
        if (this.hasNewOptionGroupTarget) {
          this.newOptionGroupTarget.classList.remove('hidden');
        }
      }
    });

    if (this.multipleValue !== true) this.closeList();
  }

  #updateSeachValue() {
    if (this.selectedValue.length === 0) return;

    if (this.selectedValue.length > 1 && this.multipleValue === true) {
      this.inputTarget.value = `${this.selectedValue.length} selected`;
      this.hiddenInputTarget.value = listItem.dataset.value;

      return;
    }

    const listItem = this.optionsTarget.querySelector(`li[data-value="${this.selectedValue[0]}"]`);
    const name = listItem.querySelector('.label').innerHTML;
    this.inputTarget.value = name;
  }

  #updateHiddenInputvalue() {
    if (this.multiple) {
      this.hiddenInputTarget.value = this.selectedValue;
    } else {
      this.hiddenInputTarget.value = this.selectedValue[0];
    }
  }
}