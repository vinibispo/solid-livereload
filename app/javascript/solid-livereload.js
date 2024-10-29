import { createConsumer } from "@rails/actioncable"
import received from "./lib/solid-livereload-received"
import scrollPosition from "./lib/solid-livereload-scroll-position"

const consumer = createConsumer()
let subscription = null

const createSubscription = () => consumer.subscriptions.create("Solid::Livereload::ReloadChannel", {
  received,

  connected() {
    console.log("[Solid::Livereload] Websocket connected")
  },

  disconnected() {
    console.log("[Solid::Livereload] Websocket disconnected")
  },
})

subscription = createSubscription()

document.addEventListener("turbo:load", () => {
  scrollPosition.restore()
  scrollPosition.remove()

  if (subscription) {
    consumer.subscriptions.remove(subscription)
    subscription = null
  }
  subscription = createSubscription()
})

