import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "display", "input", "startBtn", "pauseBtn" ]
  static values = { 
    initialTimeHms: String,
    startOnLoad: Boolean 
  }

  connect() {
    console.log("✅ Timer controller connected!");
    this.isRunning = false;
    this.timerInterval = null;
    
    this.totalSeconds = this.parseHmsToSeconds(this.initialTimeHmsValue);
    this.updateDisplay();

    // If startOnLoad is true, automatically start the countdown.
    if (this.startOnLoadValue) {
      this.start();
    }
  }

  parseHmsToSeconds(hms) {
    if (typeof hms !== 'string' || hms.length === 0) {
      return 0;
    }
    const [hours, minutes, seconds] = hms.split(':').map(Number);
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  start() {
    if (this.isRunning || this.totalSeconds <= 0) return;
    
    this.isRunning = true;
    // Gracefully handle missing targets in event mode
    if (this.hasStartBtnTarget) this.startBtnTarget.style.display = 'none';
    if (this.hasPauseBtnTarget) this.pauseBtnTarget.style.display = 'inline-block';

    this.timerInterval = setInterval(() => {
      if (this.totalSeconds > 0) {
        this.totalSeconds--;
        this.updateDisplay();
      } else {
        this.pause();
        this.totalSeconds = 0;
        this.updateDisplay();
        alert('Time is up!');
      }
    }, 1000);
  }

  pause() {
    if (!this.isRunning) return;
    
    this.isRunning = false;
    clearInterval(this.timerInterval);
    // Gracefully handle missing targets in event mode
    if (this.hasStartBtnTarget) this.startBtnTarget.style.display = 'inline-block';
    if (this.hasPauseBtnTarget) this.pauseBtnTarget.style.display = 'none';
  }

  reset() {
    this.pause();
    this.totalSeconds = 0;
    this.updateDisplay();
  }

  setCustom() {
    const minutes = parseInt(this.inputTarget.value, 10);
    if (isNaN(minutes) || minutes <= 0) {
      alert('Please enter a valid positive number of minutes.');
      return;
    }
    this.set(minutes);
    this.inputTarget.value = '';
  }

  set(minutes) {
    this.pause();
    this.totalSeconds = minutes * 60;
    this.updateDisplay();
    this.start();
  }

  updateDisplay() {
    this.displayTarget.textContent = this.formatTime(this.totalSeconds);
  }

  formatTime(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
}