# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-06-18

### Features

- Add recipe creation form from manage screen (name, yield, item link, dynamic ingredients + steps)
- Stock check walkthrough: enter current quantities, generates deficit-aware prep list
- Yield scaling stepper on recipe view (0.5× increments)
- Waste log drawer after batch logging
- Last-batch yield history badge on recipe view
- Recipe browse page with search and category grouping
- Context-aware back button on recipe view (checklist vs. browse)

### Bug Fixes

- Fix `.recipe-page__footer` inaccessible behind bottom nav — raised footer above nav bar

## [0.1.0] - 2026-06-12

### Features

- Initial alpha — PIN auth, prep checklist, recipe view, admin panel
- Staff management: add staff, toggle admin, bcrypt PIN hashing
- Items management: toggle active, edit par level
- Recipe management: archive, restore, duplicate
- JWT session (2hr exp + inactivity check)
- Supabase PostgreSQL backend, Vercel serverless deployment
