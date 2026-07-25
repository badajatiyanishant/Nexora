# Nexora

**Smart Ordering for Modern Restaurants**

Nexora Orders is a multi-tenant restaurant ordering platform. One application
serves unlimited restaurants, with every document and query scoped by
`restaurantId` so tenant data stays completely isolated.

## Products

Three products ship from a single Flutter Web binary:

| Product | Audience | Entry point |
| --- | --- | --- |
| **Customer PWA** | Diners | QR code → `/r/{slug}/menu?table={table}` |
| **Kitchen Display** | Kitchen staff | `/kitchen` |
| **Admin Dashboard** | Owners and managers | `/admin/*` |

## Tech stack

Flutter 3.x · Dart · Flutter Web (PWA) · Riverpod · GoRouter · Material 3 ·
Firebase Authentication, Cloud Firestore, Storage, and Hosting.

## Architecture

Clean Architecture, with each feature layered `domain → data → providers →
screens`. Dependencies point inward only: screens never talk to a data source
directly, so the mock repositories used for the UI milestones are swapped for
Firestore without touching a single screen.

```
lib/
  app/            application root
  core/           constants, theme, routing, utils, services
  features/       auth, customer, kitchen, admin, settings
  shared/         design-system widgets, models, repositories
  firebase/       initialisation and generated options
```

### Multi-tenancy

A QR code carries a human-readable *slug*, while Firestore data is keyed by an
immutable *restaurantId*. Keeping them separate means a restaurant can rebrand
without invalidating printed QR codes. A small public `slugs/{slug}` collection
maps between the two, and a `ShellRoute` resolves it once so no screen ever
parses a slug or receives a tenant id as a constructor argument.

```
slugs/{slug}                  → { restaurantId }
users/{uid}                   → { restaurantId, role }
restaurants/{restaurantId}
    categories/{categoryId}
    menu/{itemId}
    tables/{tableId}
    orders/{orderId}
    settings/config
```

## Roadmap

The build is UI-first, so the product can be demonstrated to restaurant owners
before any backend exists.

- [x] **M1** — Foundation: folder architecture, theme, routing, design system, splash
- [ ] **M2** — Customer UI: restaurant home, categories, menu, cart
- [ ] **M3** — Admin UI: dashboard, menu management, orders, analytics
- [ ] **M4** — Kitchen UI: live order queue
- [ ] **M5** — Firebase integration
- [ ] **M6** — Backend and business logic

## Getting started

```bash
flutter pub get
flutter run -d chrome
```
