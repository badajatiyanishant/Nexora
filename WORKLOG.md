# Ching Chong Ordering App — Worklog

## Deployment

- **Public URL:** https://badajatiyanishant.github.io/Nexora/#/
- **Menu URL:** https://badajatiyanishant.github.io/Nexora/#/r/ching-chong/menu
- **Method:** GitHub Actions → GitHub Pages
- **GitHub repo:** https://github.com/badajatiyanishant/Nexora
- **Pages setting:** Source = GitHub Actions (Settings → Pages)

## Completed

### Branding & Identity
- Browser title: "Ching Chong | Order Online"
- Splash screen: Ching Chong logo + brand gradient (#C8102E)
- Landing page: full Ching Chong branded welcome with restaurant info
- PWA manifest: Ching Chong name and description
- All "Nexora" user-visible text removed
- Restaurant-specific description: "Authentic Indo-Chinese cuisine..."
- No delivery terminology — all replaced with dine-in language

### Customer Screens
- Restaurant hero with cover image, logo, rating, prep time, price
- Sticky category chips with horizontal scrolling
- Food cards with image, badges (Bestseller/Featured), veg/non-veg, rating, prep time
- Product detail bottom sheet with large image, ingredients, spice level
- Floating animated cart bar with item count and total
- Search screen with category filters and veg-only toggle
- Cart page with quantity controls and order summary

### Pricing
- GST-inclusive pricing: menu prices include all taxes
- "All prices are inclusive of applicable taxes" notice in cart
- No separate tax calculation lines
- Grand total = items total (no hidden charges)

### Data Layer
- TenantRepository loads from bundled JSON assets
- No hardcoded restaurant data
- Restaurant, Menu, Theme all from JSON files
- Riverpod providers with correct dependency declarations

### Responsiveness
- Hero section: responsive height (38% mobile, 42% desktop)
- Product detail sheet: responsive image height (32% of screen)
- Food cards: Flexible wrapping prevents RenderFlex overflow on 360px
- Floating cart bar: overflow protection on subtotal text
- Category chips: horizontal scroll, sticky header
- All screens use Responsive utility for breakpoints

### Quality
- flutter analyze: No issues found
- flutter build web --release: succeeds
- Hash routing for GitHub Pages compatibility
- GitHub Actions workflow for auto-deploy on push

## Files Changed (customer module)

```
lib/core/constants/app_constants.dart          — Brand strings
lib/core/routing/app_router.dart               — Hash routing, real screen wiring
lib/features/auth/screens/landing_screen.dart   — Ching Chong welcome page
lib/features/auth/screens/splash_screen.dart    — Ching Chong splash
lib/features/customer/data/tenant_repository.dart — JSON asset loader
lib/features/customer/providers/cart_provider.dart — Cart state
lib/features/customer/providers/menu_provider.dart — Menu data
lib/features/customer/providers/restaurant_provider.dart — Restaurant data
lib/features/customer/providers/theme_provider.dart — Tenant theme
lib/features/customer/screens/cart_page.dart — Cart with GST-inclusive pricing
lib/features/customer/screens/customer_menu_screen.dart — Main menu
lib/features/customer/screens/search_screen.dart — Search
lib/features/customer/widgets/category_chips_bar.dart — Sticky chips
lib/features/customer/widgets/floating_cart_bar.dart — Floating cart
lib/features/customer/widgets/food_card.dart — Food item card
lib/features/customer/widgets/product_detail_sheet.dart — Product details
lib/features/customer/widgets/restaurant_hero.dart — Hero section
pubspec.yaml — Assets, flutter_web_plugins
web/index.html — Browser title, meta
web/manifest.json — PWA branding
.github/workflows/deploy.yml — GitHub Actions deploy
```

## Remaining TODOs

- [ ] Bottom navigation bar (Home / Menu / Cart / Profile)
- [ ] Table-specific ordering (QR code → table number)
- [ ] Order tracking screen
- [ ] Checkout with order type selection (Dine-In / Takeaway)
- [ ] Offline support / service worker
- [ ] Push notifications for order updates
- [ ] Payment integration (UPI / card)
- [ ] Loyalty / rewards program
- [ ] Table reservation
- [ ] Multi-language support (Hindi / English)
- [ ] Dark mode toggle
- [ ] Admin dashboard (Milestone 3)
- [ ] Kitchen display (Milestone 4)
- [ ] Firebase integration (Milestone 5)
- [ ] Custom PWA icons with Ching Chong branding
- [ ] Custom favicon with Ching Chong logo

## Known Issues

- PWA icons still use default Flutter icons (not Ching Chong branded)
- No custom favicon
- The restaurant logo is used but some category images (starter.jpg, rolls.jpg) are missing from assets
- Landing page → Menu transition could be smoother
- No haptic feedback on add-to-cart
