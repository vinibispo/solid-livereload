import received from "./lib/solid-livereload-received"

(() => {
  if(window.SolidLivereload){ return; }

  window.SolidLivereload = function({ target }) {
    const element = target.querySelector('template')?.content.getElementById('solid-livereload')
    if (element) {
      received({ force_reload: element.dataset.forceReload })
    }
  };

  document.addEventListener('turbo:before-stream-render', window.SolidLivereload);
})();

