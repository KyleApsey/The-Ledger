# The Ledger – Belle's Lounge Recipe Book

## Description
This application is meant to be used to keep track of ingredient recipes, log frequency and quantity of prep, as wel as predict when more of each item may be required.

Recipes will be focused on yield so that there is no guesswork involved while prepping.

A simple admin interface will be provided to allow for easy adding/editing of recipes.

## References
All reference recipes can be found in the `/references/` directory as JPG photo scans from the prep recipe book.

## Architecture
This project uses Nuxt.js and Vue.js, with a PostgreSQL database for data storage, Vite, and Dart Sass for styles.

### Code Style
#### Vue.js
- Always be written in Options API
- Component-based architecture
- Single file components
- No inline `<style>` contents, `<style>` tags are only used to import component Sass files

#### Sass
- Use the BEM naming convention
- Use the @use directive to import partials
- Use the @forward directive to import partials from other files
- Use the @mixin directive to define mixins
- Use the @include directive to include mixins
- Use the @function directive to define functions
- Use the @if directive to conditionally include styles
- Use the @each directive to iterate over lists
- Use the @for directive to iterate over a range of numbers

#### Component-based Architecture
- Means that components are reusable and can be used in multiple places
- Components are self-contained and can be used independently
- Components are easy to test and debug
- Components are easy to reuse
- Components are easy to change
- Components are easy to understand
- Components are easy to document
- Components are easy to maintain
- Components are easy to reuse
- Templates should be a collection of components
- Components should be as small as possible – the minute you see a `v-for` pattern or other iterative structure, that's your cue to create a smaller component to handle the logic to keep components consistent and easy to maintain
