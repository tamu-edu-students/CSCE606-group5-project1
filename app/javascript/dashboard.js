let timerInterval = null;
let totalSeconds = 0;
let isRunning = false;
let currentDate = new Date();
currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);

document.addEventListener('DOMContentLoaded', function() {
  initializeApp();
  setupNavigation();
  setupCalendarNavigation();
  updateTimerDisplay();
  fetchCurrentUser();
});

async function initializeApp() {
  try {
    await loadCalendarEvents();
  } catch (error) {
    console.error('Failed to initialize app:', error);
  }
}

function setupNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  navItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      const page = item.dataset.page;
      showPage(page);

      // Update active state
      navItems.forEach(nav => nav.classList.remove('active'));
      item.classList.add('active');
    });
  });
}

function showPage(pageId) {
  const pages = document.querySelectorAll('.page');
  pages.forEach(page => page.classList.add('hidden'));

  const targetPage = document.getElementById(pageId + 'Page');
  if (targetPage) {
    targetPage.classList.remove('hidden');
  }
}

function setupCalendarNavigation() {
  document.getElementById('prevMonth').addEventListener('click', previousMonth);
  document.getElementById('nextMonth').addEventListener('click', nextMonth);
  document.getElementById('refreshCalendar').addEventListener('click', loadCalendarEvents);
}

// Timer functions
function formatTime(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;

  return `${hours.toString().padStart(2, '0')}:${minutes
    .toString()
    .padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

function updateTimerDisplay() {
  document.getElementById('timerDisplay').textContent = formatTime(totalSeconds);
}

function startTimer() {
  if (!isRunning && totalSeconds > 0) {
    isRunning = true;
    document.getElementById('startBtn').style.display = 'none';
    document.getElementById('pauseBtn').style.display = 'inline-block';

    timerInterval = setInterval(() => {
      if (totalSeconds > 0) {
        totalSeconds--;
        updateTimerDisplay();
      } else {
        pauseTimer();
        alert('Time is up!');
      }
    }, 1000);
  }
  else {
    isRunning = true
    document.getElementById('startBtn').style.display = 'none';
    document.getElementById('pauseBtn').style.display = 'inline-block';
    timerInterval = setInterval(() => {
      totalSeconds++; 
      updateTimerDisplay();
    }, 1000);

  }
}

function setCustomTimer() {
  const input = document.getElementById('customTimerInput');
  const minutes = parseInt(input.value, 10);

  if (isNaN(minutes) || minutes <= 0) {
    alert('Please enter a valid positive number of minutes.');
    return;
  }

  setTimer(minutes);
  input.value = '';
}


function pauseTimer() {
  if (isRunning) {
    isRunning = false;
    clearInterval(timerInterval);
    document.getElementById('startBtn').style.display = 'inline-block';
    document.getElementById('pauseBtn').style.display = 'none';
  }
}

function resetTimer() {
  pauseTimer();
  totalSeconds = 0;
  updateTimerDisplay();
}

function setTimer(minutes) {
  pauseTimer();
  totalSeconds = minutes * 60;
  updateTimerDisplay();
}

// Calendar functions
function getMonthString(date) {
  return date.toLocaleDateString(undefined, { year: 'numeric', month: 'long' });
}

function firstDayOfMonth(date) {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

function lastDayOfMonth(date) {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0);
}

async function loadCalendarEvents() {
  const calendarContent = document.getElementById('calendarContent');
  calendarContent.classList.add('loading');
  calendarContent.textContent = 'Loading calendar events...';

  const startDate = firstDayOfMonth(currentDate);
  const endDate = lastDayOfMonth(currentDate);

  document.getElementById('currentMonth').textContent = getMonthString(currentDate);

  try {
    const response = await fetch(`/api/calendar_events?start_date=${startDate.toISOString()}&end_date=${endDate.toISOString()}`, {
      headers: {
        'Accept': 'application/json',
      }
    });
    if (!response.ok) throw new Error('Network response was not ok');

    const events = await response.json();
    displayCalendarEvents(events);
  } catch (error) {
    calendarContent.innerHTML = `<p style="color: red; text-align: center;">Failed to load calendar events.</p>`;
    console.error('Error loading calendar events:', error);
  } finally {
    calendarContent.classList.remove('loading');
  }
}

function displayCalendarEvents(events) {
  const calendarContent = document.getElementById('calendarContent');
  if (!events || events.length === 0) {
    calendarContent.innerHTML = `
      <div style="text-align: center; padding: 2rem; color: #86868b;">
        <p>No events found for this month</p>
      </div>
    `;
    return;
  }

  const eventsHTML = events.map(event => {
    const eventStart = new Date(event.start);
    const eventEnd = new Date(event.end);
    const isAllDay = event.start.length <= 10;

    return `
      <div style="
          padding: 1rem; 
          border-left: 4px solid #007aff; 
          background: #f8f9ff; 
          margin-bottom: 1rem; 
          border-radius: 0 8px 8px 0;
      ">
          <h3 style="color: #1d1d1f; margin-bottom: 0.5rem;">${event.summary || 'Untitled Event'}</h3>
          <p style="color: #86868b; font-size: 0.9rem; margin-bottom: 0.5rem;">
              📅 ${eventStart.toLocaleDateString()} 
              ${!isAllDay ? `⏰ ${eventStart.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} - ${eventEnd.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}` : 'All day'}
          </p>
      </div>
    `;
  }).join('');

  calendarContent.innerHTML = eventsHTML;
}

function previousMonth() {
  currentDate.setMonth(currentDate.getMonth() - 1);
  loadCalendarEvents();
}

function nextMonth() {
  currentDate.setMonth(currentDate.getMonth() + 1);
  loadCalendarEvents();
}

function logout() {
  fetch('/logout', {
    method: 'DELETE',
    headers: { 
      'X-CSRF-Token': getCsrfToken(),
      'Content-Type': 'application/json'
    }
  })
  .then(res => {
    if (res.ok) {
      window.location.href = '/';
    } else {
      alert('Logout failed.');
    }
  })
  .catch(() => alert('Logout failed.'));
}

function getCsrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
}

// Fetch current user info and display it
async function fetchCurrentUser() {
  try {
    const res = await fetch('/api/current_user', { headers: { 'Accept': 'application/json' } });
    if (!res.ok) throw new Error('Failed to fetch user');

    const user = await res.json();
    const userNameElements = document.querySelectorAll('.user-name');
    userNameElements.forEach(element => {
      if (element.classList.contains('page-title')) {
        element.textContent = `Hi ${user.first_name || 'User'}`;
      } else {
        element.textContent = user.name || 'User';
      }
    });

    document.getElementById('userAvatar').textContent = (user.name ? user.name[0].toUpperCase() : 'U');
  } catch (error) {
    console.warn('Could not fetch user info:', error);
    document.getElementById('userName').textContent = 'Guest';
    document.getElementById('userAvatar').textContent = 'G';
  }
}

// Make functions global so inline onclick can find them
window.startTimer = startTimer;
window.setCustomTimer = setCustomTimer;
window.pauseTimer = pauseTimer;
window.resetTimer = resetTimer;
window.setTimer = setTimer;
window.previousMonth = previousMonth;
window.nextMonth = nextMonth;
window.loadCalendarEvents = loadCalendarEvents;
window.logout = logout;
