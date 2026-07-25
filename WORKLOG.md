# Ching Chong — QR-Based Restaurant Ordering System

## Deployment

- **Public URL:** https://badajatiyanishant.github.io/Nexora/#/
- **Menu URL:** https://badajatiyanishant.github.io/Nexora/#/r/ching-chong/menu
- **Kitchen URL:** https://badajatiyanishant.github.io/Nexora/#/kitchen
- **Admin URL:** https://badajatiyanishant.github.io/Nexora/#/admin/dashboard
- **Method:** GitHub Actions → GitHub Pages (auto-deploy on push)
- **GitHub repo:** https://github.com/badajatiyanishant/Nexora
- **Pages setting:** Source = GitHub Actions

## Completed

### Customer Flow (10 screens)
1. **Splash** — Ching Chong logo animation with brand gradient
2. **Landing** — Restaurant branding, "Scan Table QR" + "Browse Menu" buttons
3. **QR Scanner** — Mock scanner with animated frame, torch toggle, corner accents, scan line
4. **Restaurant Home** — Hero with cover, logo, table chip, categories, food cards, search
5. **Food Detail** — Bottom sheet with large image, ingredients, spice level, quantity selector
6. **Cart** — GST-inclusive pricing, quantity controls, special instructions, place order
7. **Order Success** — Animated checkmark, order #, table, prep time
8. **Order Tracking** — Animated timeline (Received → Accepted → Preparing → Ready → Delivered)
9. **Search** — Category filters, veg-only toggle, instant filtering
10. **Floating Cart** — Animated bottom bar with item count and total

### Kitchen Panel
- Three-column layout: New / Preparing / Ready / Completed
- Order cards with table number, items, special instructions, elapsed time
- Accept/Advance/Complete status buttons
- Tablet-optimized design

### Owner Dashboard
- Sidebar navigation (Dashboard / Menu / QR Codes / Settings)
- Metric cards (orders, revenue, active, completed)
- Popular dishes section
- Recent orders list
- Menu management with category toggles and item counts
- Restaurant settings (info, timings)
- Kitchen quick-access link

### Backend Infrastructure (Firestore-ready)
- Abstract repository interfaces: Restaurant, Menu, Order, Table
- RestaurantOrder + OrderLine models
- OrdersNotifier with placeOrder, advanceOrder, cancelOrder
- Updated OrderStatus: received → accepted → preparing → ready → delivered
- Firestore schema document with planned collections
- TenantRepository loads from bundled JSON assets
- All providers with correct Riverpod dependencies

### Design & Quality
- Ching Chong branding everywhere (logo, colors, text)
- No Nexora references in user-visible code
- No delivery terminology (all replaced with dine-in)
- GST-inclusive pricing (no tax calculations)
- Hash routing for GitHub Pages
- Responsive hero (38%/42% of screen height)
- Responsive product detail sheet (32% of screen)
- Flexible wrapping prevents RenderFlex overflow on 360px
- Overflow protection on floating cart subtotal
- Material 3 design system with premium shadows
- PWA manifest with Ching Chong branding

## Files Modified

### Customer Module
```
lib/features/customer/data/tenant_repository.dart
lib/features/customer/providers/cart_provider.dart
lib/features/customer/providers/menu_provider.dart
lib/features/customer/providers/restaurant_provider.dart
lib/features/customer/providers/theme_provider.dart
lib/features/customer/screens/cart_page.dart
lib/features/customer/screens/customer_menu_screen.dart
lib/features/customer/screens/order_success_screen.dart
lib/features/customer/screens/order_tracking_screen.dart
lib/features/customer/screens/search_screen.dart
lib/features/customer/screens/table_scanner_screen.dart
lib/features/customer/widgets/category_chips_bar.dart
lib/features/customer/widgets/floating_cart_bar.dart
lib/features/customer/widgets/food_card.dart
lib/features/customer/widgets/product_detail_sheet.dart
lib/features/customer/widgets/restaurant_hero.dart
```

### Kitchen Module
```
lib/features/kitchen/screens/kitchen_screen.dart
```

### Owner Module
```
lib/features/owner/screens/owner_dashboard.dart
```

### Auth Module
```
lib/features/auth/screens/landing_screen.dart
lib/features/auth/screens/splash_screen.dart
```

### Shared
```
lib/shared/models/order.dart
lib/shared/providers/orders_provider.dart
lib/shared/repositories/restaurant_repository.dart
lib/shared/repositories/menu_repository.dart
lib/shared/repositories/order_repository.dart
lib/shared/repositories/table_repository.dart
lib/firebase/firestore_schema.dart
```

### Core
```
lib/core/constants/app_constants.dart
lib/core/constants/enums.dart
lib/core/routing/app_router.dart
lib/core/routing/route_paths.dart
```

### Config
```
pubspec.yaml
web/index.html
web/manifest.json
.github/workflows/deploy.yml
WORKLOG.md
```

## Git Commits (this session)
1. `feat: customer ordering UI + GitHub Pages deployment`
2. `fix: match Flutter version in CI to local (3.44.x)`
3. `fix: clean analyzer, remove delivery refs, add flutter_web_plugins dep`
4. `feat: Ching Chong branding + GST-inclusive pricing`
5. `fix: responsive overflow fixes + responsive hero/sheet heights`
6. `feat: data-driven offer cards + WORKLOG.md`
7. `feat: order model + orders provider (mock, in-memory)`
8. `feat: complete customer + kitchen + owner flow (UI-only, mock data)`
9. `fix: QR scanner flashlight toggle with animation and lifecycle`
10. `feat: repository abstractions + Firestore schema + shared_preferences`

## Remaining TODOs

### High Priority
- [ ] Firebase integration (needs project credentials)
- [ ] Firestore realtime sync for orders
- [ ] Real QR code generation (table URLs)
- [ ] Cart persistence with SharedPreferences
- [ ] Dark mode support
- [ ] PWA service worker for offline support
- [ ] Custom favicon and PWA icons

### Medium Priority
- [ ] Push notifications for order updates
- [ ] Sound/vibration when new order arrives in kitchen
- [ ] Table management (occupied/available status)
- [ ] Real-time table status on customer screens
- [ ] Special instructions per item in food detail
- [ ] Multi-language support (Hindi/English)
- [ ] Owner can toggle item availability from dashboard

### Low Priority
- [ ] Payment integration (UPI/card)
- [ ] Loyalty/rewards program
- [ ] Table reservation system
- [ ] Analytics export (PDF/CSV)
- [ ] Staff authentication
- [ ] Multi-restaurant admin panel

## Known Issues
- QR scanner is mock-only (no real camera access)
- PWA icons still use default Flutter icons
- No custom favicon
- Missing category images: starter.jpg, rolls.jpg
- No sound/vibration for kitchen notifications
- Landing page → Menu transition could be smoother
- No haptic feedback on add-to-cart

## Architecture
- **State:** Riverpod 2.x
- **Routing:** GoRouter with hash strategy
- **Data:** In-memory (mock), repository interfaces ready for Firestore
- **UI:** Material 3, custom design system
- **Deployment:** GitHub Actions → GitHub Pages
