// Stimulus controller for countdown timer functionality
// Provides interactive timer controls for coding sessions and time management

import { Controller } from "@hotwired/stimulus"

// Timer controller class extending Stimulus Controller
export default class extends Controller {
  // Define DOM targets that this controller can interact with
  static targets = [ "display", "input", "startBtn", "pauseBtn" ]
  
  // Define data values that can be passed from HTML data attributes
  static values = {
    initialTimeHms: String,  // Initial time in HH:MM:SS format
    startOnLoad: Boolean     // Whether to auto-start timer when controller connects
  }

  // Called when the controller is connected to the DOM
  connect() {
    console.log("✅ Timer controller connected!");
    
    // Initialize timer state
    this.isRunning = false;      // Track if timer is currently running
    this.timerInterval = null;   // Store interval ID for cleanup
    
    // Parse initial time and update display
    this.totalSeconds = this.parseHmsToSeconds(this.initialTimeHmsValue);
    this.updateDisplay();

    // Auto-start timer if configured to do so
    if (this.startOnLoadValue) {
      this.start();
    }
  }

  // Parse HH:MM:SS time string into total seconds
  // @param {string} hms - Time string in HH:MM:SS format
  // @returns {number} Total seconds
  parseHmsToSeconds(hms) {
    // Handle invalid or empty input
    if (typeof hms !== 'string' || hms.length === 0) {
      return 0;
    }
    
    // Split time string and convert to numbers
    const [hours, minutes, seconds] = hms.split(':').map(Number);
    
    // Calculate total seconds
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  // Start the countdown timer
  start() {
    // Don't start if already running or no time remaining
    if (this.isRunning || this.totalSeconds <= 0) return;
    
    // Update state and UI
    this.isRunning = true;
    
    // Gracefully handle missing targets (some views may not have all buttons)
    if (this.hasStartBtnTarget) this.startBtnTarget.style.display = 'none';
    if (this.hasPauseBtnTarget) this.pauseBtnTarget.style.display = 'inline-block';

    // Start countdown interval (updates every second)
    this.timerInterval = setInterval(() => {
      if (this.totalSeconds > 0) {
        this.totalSeconds--;     // Decrement time
        this.updateDisplay();    // Update display
      } else {
        // Timer finished
        this.pause();
        this.totalSeconds = 0;
        this.updateDisplay();
        alert('Time is up!');    // Notify user
      }
    }, 1000);
  }

  // Pause the countdown timer
  pause() {
    // Don't pause if not running
    if (!this.isRunning) return;
    
    // Update state and clear interval
    this.isRunning = false;
    clearInterval(this.timerInterval);
    
    // Update button visibility (gracefully handle missing targets)
    if (this.hasStartBtnTarget) this.startBtnTarget.style.display = 'inline-block';
    if (this.hasPauseBtnTarget) this.pauseBtnTarget.style.display = 'none';
  }

  // Reset timer to zero
  reset() {
    this.pause();              // Stop timer if running
    this.totalSeconds = 0;     // Reset time to zero
    this.updateDisplay();      // Update display
  }

  // Set custom timer duration from user input
  setCustom() {
    // Parse and validate user input
    const minutes = parseInt(this.inputTarget.value, 10);
    if (isNaN(minutes) || minutes <= 0) {
      alert('Please enter a valid positive number of minutes.');
      return;
    }
    
    // Set timer and clear input
    this.set(minutes);
    this.inputTarget.value = '';
  }

  // Set timer to specific number of minutes and start
  // @param {number} minutes - Number of minutes to set timer for
  set(minutes) {
    this.pause();                      // Stop current timer
    this.totalSeconds = minutes * 60;  // Convert minutes to seconds
    this.updateDisplay();              // Update display
    this.start();                      // Start new timer
  }

  // Update the timer display with current time
  updateDisplay() {
    this.displayTarget.textContent = this.formatTime(this.totalSeconds);
  }

  // Format seconds into HH:MM:SS display format
  // @param {number} seconds - Total seconds to format
  // @returns {string} Formatted time string (HH:MM:SS)
  formatTime(seconds) {
    // Calculate hours, minutes, and seconds
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    // Format with leading zeros and return
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
}