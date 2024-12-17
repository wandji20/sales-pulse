import Flatpickr from 'stimulus-flatpickr'

export default class extends Flatpickr {
  static values = { initConf: { } }


  connect() {
    this.config = {
      ...this.initConfValue
    }

    super.connect();
  }
}