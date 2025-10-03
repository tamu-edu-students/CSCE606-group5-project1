import { application } from "controllers/application"

// Eager load all controllers defined in the import map under the controllers folder.
// This is the key part that will find and load your timer_controller.js
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
