import {Controller} from "@hotwired/stimulus"

import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

export default class extends Controller {
  static targets = ['chart'];
  static values = { config: { type: Object, default: {}} }

  connect() {
    new Chart(this.canvasContext(), this.configValue);
  }

  canvasContext() {
      return this.chartTarget.getContext('2d');
  }
}