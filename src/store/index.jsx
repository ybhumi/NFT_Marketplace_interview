import { createGlobalState } from 'react-hooks-global-state';

// Create global state variables and corresponding functions
const { setGlobalState, useGlobalState, getGlobalState } = createGlobalState({
  modal: 'scale-0', // Tailwind CSS class
  updateModal: 'scale-0',
  showModal: 'scale-0',
  alert: { show: false, msg: '', color: '' },
  loading: { show: false, msg: '' },
  connectedAccount: '',
  nft: null,
  nfts: [],

  contract: null,
});

// Set an alert message with an optional color
const setAlert = (msg, color = 'green') => {
  setGlobalState('loading', false);
  setGlobalState('alert', { show: true, msg, color });
  setTimeout(() => {
    setGlobalState('alert', { show: false, msg: '', color });
  }, 6000);
};

// Set the loading message
const setLoadingMsg = (msg) => {
  const loading = getGlobalState('loading');
  setGlobalState('loading', { ...loading, msg });
};

// Truncate a text with ellipsis if it exceeds the maximum length
const truncate = (text, startChars, endChars, maxLength) => {
  if (text.length > maxLength) {
    var start = text.substring(0, startChars);
    var end = text.substring(text.length - endChars, text.length);
    while (start.length + end.length < maxLength) {
      start = start + '.';
    }
    return start + end;
  }
  return text;
};

// Export the global state variables and functions
export {
  useGlobalState,
  setGlobalState,
  getGlobalState,
  setAlert,
  setLoadingMsg,
  truncate,
};
