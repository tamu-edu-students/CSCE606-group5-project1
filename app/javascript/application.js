// This should be the first line, to start Turbo
import "@hotwired/turbo-rails"

// This line is crucial. It loads controllers/index.js
import "controllers"

// let timerInterval = null;
// let totalSeconds = 0;
// let isRunning = false;
// let currentDate = new Date();
// currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);

// document.addEventListener('DOMContentLoaded', function() {
//   updateTimerDisplay();
// });

// function formatTime(seconds) {
//   const hours = Math.floor(seconds / 3600);
//   const minutes = Math.floor((seconds % 3600) / 60);
//   const secs = seconds % 60;

//   return `${hours.toString().padStart(2, '0')}:${minutes
//     .toString()
//     .padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
// }

// function updateTimerDisplay() {
//   document.getElementById('timerDisplay').textContent = formatTime(totalSeconds);
// }

// function startTimer() {
//   if (!isRunning && totalSeconds > 0) {
//     isRunning = true;
//     document.getElementById('startBtn').style.display = 'none';
//     document.getElementById('pauseBtn').style.display = 'inline-block';

//     timerInterval = setInterval(() => {
//       if (totalSeconds > 0) {
//         totalSeconds--;
//         updateTimerDisplay();
//       } else {
//         pauseTimer();
//         alert('Time is up!');
//       }
//     }, 1000);
//   }
//   else {
//     isRunning = true
//     document.getElementById('startBtn').style.display = 'none';
//     document.getElementById('pauseBtn').style.display = 'inline-block';
//     timerInterval = setInterval(() => {
//       totalSeconds++; 
//       updateTimerDisplay();
//     }, 1000);

//   }
// }

// function setCustomTimer() {
//   const input = document.getElementById('customTimerInput');
//   const minutes = parseInt(input.value, 10);

//   if (isNaN(minutes) || minutes <= 0) {
//     alert('Please enter a valid positive number of minutes.');
//     return;
//   }

//   setTimer(minutes);
//   startTimer();
//   input.value = '';
// }


// function pauseTimer() {
//   if (isRunning) {
//     isRunning = false;
//     clearInterval(timerInterval);
//     document.getElementById('startBtn').style.display = 'inline-block';
//     document.getElementById('pauseBtn').style.display = 'none';
//   }
// }

// function resetTimer() {
//   pauseTimer();
//   totalSeconds = 0;
//   updateTimerDisplay();
// }

// function setTimer(minutes) {
//   pauseTimer();
//   totalSeconds = minutes * 60;
//   updateTimerDisplay();
// }

// window.startTimer = startTimer;
// window.setCustomTimer = setCustomTimer;
// window.pauseTimer = pauseTimer;
// window.resetTimer = resetTimer;
// window.setTimer = setTimer;
