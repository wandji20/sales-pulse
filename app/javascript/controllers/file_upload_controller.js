import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['fileInput', 'filename']

  openFileInput() {
    this.fileInputTarget.click();
  }

  setFilename(e) {
    this.filenameTarget.innerHTML = e.target.files[0].name
  }
}