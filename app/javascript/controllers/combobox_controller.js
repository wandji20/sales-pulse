import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { searchUrl: String, selected: { type: String, default: '' } }
  static targets = ["input", "hiddenInput", "label", "options", "newOptionGroup"]

  connect() {
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
    this.selectedValue = event.currentTarget.dataset.value;
    this.#updateSelectedOption();
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
      this.newOptionGroupTarget.querySelector("input[name='add_customer']").value = 'true';
      this.newOptionGroupTarget.classList.remove('hidden');
    } else {
      this.newOptionGroupTarget.querySelector("input[name='add_customer']").value = 'false';
      this.newOptionGroupTarget.classList.add('hidden');
    }
  }

  #updateSelectedOption() {
    const listItem = this.optionsTarget.querySelector(`li[data-value="${this.selectedValue}"]`);

    // Update input value to selected name
    const name = listItem.querySelector('.label').innerHTML
    this.inputTarget.value = name;

    // Mark selected option
    this.optionsTarget.querySelectorAll('li').forEach(option => {
      option.classList.remove('selected');
    });

    if (!listItem)
      return;

    listItem.classList.add('selected');
  
    // set value for hidden input
    if (listItem.dataset.value === 'new') {
      if (this.hasNewOptionGroupTarget) {
        this.newOptionGroupTarget.classList.remove('hidden')
        this.newOptionGroupTarget.querySelector("input[name='customer[name]']").value = name;
      }
    } else {
      this.hiddenInputTarget.value = listItem.dataset.value;
    }

    this.closeList();
  }
}