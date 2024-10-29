import debounce from "debounce"
import scrollPosition from "./solid-livereload-scroll-position"

export default debounce(({force_reload}) => {
  const onErrorPage = document.title === "Action Controller: Exception caught"

  if (onErrorPage || force_reload) {
    console.log("[Solid::Livereload] Files changed. Force reloading..")
    document.location.reload()
  } else {
    console.log("[Solid::Livereload] Files changed. Reloading..")
    scrollPosition.save()
    Turbo.cache.clear()
    Turbo.visit(window.location.href, { action: 'replace' })
  }
}, 300)
