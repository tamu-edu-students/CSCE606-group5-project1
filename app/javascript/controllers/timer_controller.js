import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "display", "input", "startBtn", "pauseBtn" ]

  connect() {
    console.log("✅ Timer controller connected!");
    this.totalSeconds = 0;
    this.isRunning = false;
    this.timerInterval = null;
    this.updateDisplay();
  }

  start() {
    if (this.isRunning) return;
    
    this.isRunning = true;
    this.startBtnTarget.style.display = 'none';
    this.pauseBtnTarget.style.display = 'inline-block';

    this.timerInterval = setInterval(() => {
      if (this.totalSeconds > 0) {
        this.totalSeconds--;
        this.updateDisplay();
      } else {
        this.pause();
        alert('Time is up!');
      }
    }, 1000);
  }

  pause() {
    if (!this.isRunning) return;
    
    this.isRunning = false;
    clearInterval(this.timerInterval);
    this.startBtnTarget.style.display = 'inline-block';
    this.pauseBtnTarget.style.display = 'none';
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