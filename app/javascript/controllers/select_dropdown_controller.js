import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { searchUrl: String, selected: { type: Array, default: [] }, multiple: false, params: String }
  static targets = ["button", "input", "label", "options", "option", "placeholder", "newOptionGroup"]

  connect() {
    this.fieldName = this.element.dataset.fieldName;
    this.filterTarget = this.element.dataset.filterTarget;

    this.#setDisplayValue();
    document.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  search(_e, hideOptions = false) {
    if (!this.searchUrlValue) return;
    clearTimeout(this.debouncedSearch);

    this.debouncedSearch = setTimeout(async () => {
      if (this.inputTarget.value === '') {
        this.selectedValue = [];
      }
    
      const response = await fetch(
        `${this.searchUrlValue}?search=${this.inputTarget.value}&${this.paramsValue}&hide=${hideOptions}`,
        { headers: { "Accept": "text/vnd.turbo-stream.html" } }
      );
      const streamContent = await response.text();
      await Turbo.renderStreamMessage(streamContent);
    
    }, 500);
  }

  filter(e) {
    // Reset selected values and search
    this.selectedValue = [];
    this.#setDisplayValue();
    this.paramsValue = e.detail.params;
    this.search(null, true);
  }

  toggleOption(e) {
    const value = e.target.closest('li').dataset.value;
    this.#updateValues(value);
  }

  closeList(event = null) {
    // Prevent closing modal and hide options
    if (event)
      event.stopPropagation();
    this.optionsTarget.classList.add('hidden');
  }

  toggleDropdown() {
    if (this.hasInputTarget) {
      this.inputTarget.focus();
    } else {
      this.buttonTarget.focus();
    }
  
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
    // this.#updateOptionsQueryParams();
  }

  #markSelected() {
    this.optionTargets.forEach((option) => {
      const checkbox = option.querySelector('input[type="checkbox"]');
      const optionValue = option.dataset.value;
      if (this.selectedValue.includes(optionValue)) {
        if (checkbox) checkbox.checked = true;
      } else {
        if (checkbox) checkbox.checked = false;
      }
    })

    this.#sendFilterEvent();
  }

  #setDisplayValue() {
    if (this.selectedValue.length === 0) {
      if (this.hasInputTarget) {
        this.inputTarget.value = '';
      } else {
        const span = this.buttonTarget.querySelector("span");
        span.innerHTML = null;
        span.appendChild(this.placeholderTarget.content.cloneNode(true))
      }

      return
    }
  
    let label = this.optionsTarget.querySelector(`li[data-value="${this.selectedValue[0]}"]`)
                                  .dataset.label;

    if (this.multipleValue) {
      const total = this.selectedValue.filter(val => val !== 'all').length;
      if (total > 1) label = `${total} selected`;
    }

    if (this.hasInputTarget) {
      this.inputTarget.value = label;
    } else {
      const span = this.buttonTarget.querySelector("span");
      span.innerHTML = label;
    }
  }

  #sendFilterEvent() {
    // set params and dispatch controller selected event
    if (this.fieldName && this.filterTarget) {
      let params = new URLSearchParams();

      this.selectedValue.forEach(val => {
        params.append(this.fieldName, val);
      });

      document.querySelector(this.filterTarget).dispatchEvent(
        new CustomEvent(
          "dropdown:selected",
          { detail: { params: params.toString() } }
        )
      );
    }
  }
}