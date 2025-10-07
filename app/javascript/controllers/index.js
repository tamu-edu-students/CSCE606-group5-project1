// Stimulus controllers index file
// Automatically loads all Stimulus controllers from the controllers directory

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under the controllers folder.
// This is the key part that will find and load your timer_controller.js and any other controllers
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Automatically discover and register all controllers in the controllers directory
eagerLoadControllersFrom("controllers", application)
