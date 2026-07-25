/// Firestore collection schema for Ching Chong ordering system.
///
/// This file documents the planned Firestore structure. Nothing here is
/// executed — it serves as a contract for when Firebase is integrated.
///
/// ## Collections
///
/// ```
/// restaurants/
///   {slug}/
///     name: "Ching Chong"
///     slug: "ching-chong"
///     address: { line1, line2, city, state, postalCode, landmark }
///     contact: { phonePrimary, phoneSecondary, email, instagram }
///     service: { dineIn, takeaway, averagePrepMinutes, taxPercent }
///     hours: [{ day, opensAt, closesAt }]
///     highlights: [{ icon, label, value }]
///
///     menu/
///       categories/
///         {categoryId}/
///           id, name, description, image, icon, sortOrder
///
///       items/
///         {itemId}/
///           id, categoryId, name, description, price
///           foodType, portion, prepMinutes, spiceLevel
///           available, featured, bestseller, rating, ratingCount
///
///     tables/
///       {tableId}/
///         id, label, seats, zone, status
///
///     orders/
///       {orderId}/
///         id, tableNumber, restaurantId
///         status: received | accepted | preparing | ready | delivered
///         lines: [{ itemId, name, price, quantity, instructions }]
///         subtotal, placedAt, updatedAt
///
///     theme/
///       light: { primary, secondary, background, ... }
///       dark: { primary, secondary, background, ... }
///       heroGradient, accentGradient, logoBackdrop
/// ```
///
/// ## Security Rules (planned)
///
/// - Customers: read-only on `restaurants/{slug}/menu`
/// - Customers: create orders in `restaurants/{slug}/orders`
/// - Kitchen: read/write orders in own restaurant
/// - Owner: full CRUD on own restaurant subcollections
///
/// ## Realtime Listeners
///
/// - Kitchen: `watchOrders(slug)` → orders where status ∈ [received, accepted, preparing, ready]
/// - Customer: `watchOrder(slug, orderId)` → single order for status tracking
/// - Owner: `watchOrders(slug)` → all orders for dashboard
class FirestoreSchema {
  FirestoreSchema._();
}
