# Magic Food Restaurant Application

Magic Food is a comprehensive, production-grade restaurant management and food ordering application built with Flutter and Supabase. The system delivers a seamless end-to-end experience for both customers and restaurant administrators, featuring real-time order tracking, customer-admin communication, financial analytics, dynamic vouchers, and multi-language support.

---

## Technical Stack

| Domain | Technology / Library | Description |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart SDK 3.x) | Cross-platform UI toolkit for iOS, Android, Web, and Desktop |
| **Backend Service** | Supabase | PostgreSQL Database, Authentication, and Realtime Engine |
| **Architecture** | Clean Architecture | Layered architecture separating Core, Domain Models, Data, and Presentation |
| **State Management** | ChangeNotifier / ListenableBuilder | Reactive, lightweight state propagation across app features |
| **Localization** | Custom Language Service | Persistent multi-language switcher supporting Indonesian and English |
| **Notifications** | Local Notification Service | Device notification integration and unread status tracking |
| **Reporting & Export** | Custom PDF Print Service | Thermal receipt generator and PDF export utility |

---

## Core Capabilities

### Customer Experience
- **Interactive Food Catalog**: Categorized menu browsing with ratings, search functionality, and formatted local pricing.
- **Cart & Checkout Engine**: Shopping cart management with real-time price calculation, coupon/voucher validation, and shipping address entry.
- **Order Tracking**: Visual status timeline tracking order progress from preparation to courier delivery.
- **Real-Time Customer Support**: Direct chat interface connected with restaurant administration via Supabase Realtime with automated fallback mechanisms.
- **Loyalty Rewards**: Automated point accumulation upon successful order completion.

### Administrator Dashboard ("Magic Food Admin")
- **Kitchen Operational Dashboard**: Overview of active kitchen workload, queue counts, and urgent order alerts.
- **Order Processing & Courier Dispatch**: Multi-stage order state management (Pending, Cooking, On Delivery, History) with courier assignment and live delivery tracking.
- **Real-Time Order Chat**: Dedicated admin chat portal for instantaneous customer communication.
- **Financial Analytics**: Interactive revenue metrics (Today vs. Date Range totals), weekly revenue trend bar charts, and dynamic date range pickers.
- **Sales Activity Log**: Real-time log of customer transactions directly synchronized with database records.
- **Print & PDF Receipt Generator**: On-demand thermal receipt preview and PDF export for order archiving.
- **System Settings**: Restaurant profile management, sound notification alerts, auto-accept toggles, and language preferences.

---

## Application Screenshots

### Customer Application Interface
| Homepage & Recommendations | Menu Catalog & Search | Order Tracking & Map (BTM) |
| :---: | :---: | :---: |
| <img src="assets/screenshots/home.png" width="260" alt="Customer Homepage" /> | <img src="assets/screenshots/search.png" width="260" alt="Menu Search Catalog" /> | <img src="assets/screenshots/tracking.png" width="260" alt="Order Tracking Map" /> |

### Administrator Dashboard ("Magic Food Admin")
| Orders Management & Driver Dispatch | Real-Time Financial Analytics |
| :---: | :---: |
| <img src="assets/screenshots/admin_orders.png" width="340" alt="Admin Orders Dispatch" /> | <img src="assets/screenshots/admin_financials.png" width="340" alt="Admin Financial Analytics" /> |

---

## System Architecture & Directory Structure

The repository follows standard Clean Architecture principles to ensure maintainability, scalability, and code separation.

```text
lib/
├── core/
│   ├── models/            # Shared domain models (OrderData, ChatMessageItem, FoodModel)
│   ├── services/          # Singleton services (ChatService, CartService, LanguageService, NotificationService)
│   ├── theme/             # Design tokens, color palettes, and global typography
│   └── widgets/           # Reusable UI components (FoodCard, AnimatedTouchable)
├── features/
│   ├── admin/             # Administrator Dashboard feature set
│   │   ├── data/          # Admin data repository and analytics calculation logic
│   │   ├── models/        # Financial and courier domain models
│   │   └── presentation/  # Admin tabs, header, bottom navigation, and receipt dialogs
│   ├── dashboard/         # Customer dashboard, order history, tracking, and chat pages
│   ├── home/              # Homepage, categories, banners, and search components
│   ├── onboarding/        # Initial onboarding screens
│   ├── profile/           # User account details, notifications, points, and settings
│   └── splash/            # Application splash initialization screen
└── main.dart              # Application entry point and global provider bindings
```

---

## Database Setup & Supabase SQL Script

Untuk mempermudah setup backend Supabase, berikut adalah kode SQL lengkap (DDL, RLS Policies, dan Realtime Configuration) yang dapat Anda langsung *copy-paste* ke **Supabase SQL Editor**.

```sql
-- ========================================================
-- 1. CREATE TABLES (DATABASE SCHEMA & RELATIONS)
-- ========================================================

-- Table: menu_items
CREATE TABLE IF NOT EXISTS public.menu_items (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    nama varchar NOT NULL,
    kategori varchar NOT NULL,
    harga integer NOT NULL,
    lama_pembuatan_menit integer NOT NULL,
    rating numeric,
    image_url text,
    created_at timestamptz DEFAULT now()
);

-- Table: orders
CREATE TABLE IF NOT EXISTS public.orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    order_number varchar NOT NULL,
    status varchar NOT NULL DEFAULT 'pending',
    total_price integer NOT NULL,
    catatan text,
    created_at timestamptz DEFAULT now(),
    alamat_pengiriman text
);

-- Table: order_items
CREATE TABLE IF NOT EXISTS public.order_items (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
    menu_item_id bigint REFERENCES public.menu_items(id) ON DELETE SET NULL,
    nama_makanan varchar NOT NULL,
    kategori varchar NOT NULL,
    harga_satuan integer NOT NULL,
    jumlah integer NOT NULL,
    subtotal integer NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Table: order_chats
CREATE TABLE IF NOT EXISTS public.order_chats (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
    sender_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    message text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- ========================================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS)
-- ========================================================

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_chats ENABLE ROW LEVEL SECURITY;

-- ========================================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================

-- --------------------------------------------------------
-- Policies for: menu_items
-- --------------------------------------------------------
CREATE POLICY "Bisa lihat menu" 
ON public.menu_items 
FOR SELECT 
TO public 
USING (true);

-- --------------------------------------------------------
-- Policies for: orders
-- --------------------------------------------------------
CREATE POLICY "Admin full access orders" 
ON public.orders 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);

CREATE POLICY "Bisa bikin order" 
ON public.orders 
FOR INSERT 
TO public 
WITH CHECK (true);

CREATE POLICY "Bisa lihat order sendiri" 
ON public.orders 
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "Customer insert own orders" 
ON public.orders 
FOR INSERT 
TO public 
WITH CHECK (true);

CREATE POLICY "Customer read own orders" 
ON public.orders 
FOR SELECT 
TO public 
USING (true);

-- --------------------------------------------------------
-- Policies for: order_items
-- --------------------------------------------------------
CREATE POLICY "Admin full access order_items" 
ON public.order_items 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);

CREATE POLICY "Bisa lihat item pesanan" 
ON public.order_items 
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "Bisa masukin item" 
ON public.order_items 
FOR INSERT 
TO public 
WITH CHECK (true);

CREATE POLICY "Customer Insert own order_items" 
ON public.order_items 
FOR INSERT 
TO public 
WITH CHECK (true);

CREATE POLICY "Customer read own order_items" 
ON public.order_items 
FOR SELECT 
TO public 
USING (true);

-- --------------------------------------------------------
-- Policies for: order_chats
-- --------------------------------------------------------
CREATE POLICY "Izinkan pengguna terautentikasi mengirim chat" 
ON public.order_chats 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

CREATE POLICY "Izinkan semua pengguna terautentikasi membaca chat" 
ON public.order_chats 
FOR SELECT 
TO authenticated 
USING (true);

-- ========================================================
-- 4. ENABLE SUPABASE REALTIME REPLICATION
-- ========================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.order_chats;

-- ========================================================
-- 5. SEED INITIAL DATA (OPTIONAL MENU DUMMY DATA)
-- ========================================================

INSERT INTO public.menu_items (nama, kategori, harga, lama_pembuatan_menit, rating, image_url) VALUES
('Nasi Goreng Spesial', 'Makanan Utama', 25000, 15, 4.8, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b'),
('Mie Goreng Seafood', 'Makanan Utama', 28000, 15, 4.7, 'https://images.unsplash.com/photo-1585032226651-759b368d7246'),
('Ayam Bakar Madu', 'Makanan Utama', 32000, 20, 4.9, 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b'),
('Es Teh Manis', 'Minuman', 5000, 5, 4.9, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc'),
('Kopi Susu Gula Aren', 'Minuman', 18000, 7, 4.9, 'https://images.unsplash.com/photo-1541167760496-1628856ab772');
```

---

## Getting Started

### Default Administrator Credentials
- **Email**: `admin@gmail.com`
- **Password**: `123456`
- **Role**: `ADMIN`

### Prerequisites
- Flutter SDK (version 3.19.0 or higher)
- Dart SDK (version 3.3.0 or higher)
- Android Studio / VS Code with Flutter extension
- Active Supabase project with Database and Authentication enabled

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/DimasAnwar/RestaurantApp.git
   cd restauran_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Environment Variables (`.env`):
   Salin file `.env.example` menjadi `.env` di root project:
   ```bash
   cp .env.example .env
   ```
   Buka file `.env` lalu isikan kredensial Supabase Project URL & Anon Key milik Anda:
   ```env
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key-here
   ```

4. Run the application:
   ```bash
   flutter run
   ```

---

## Code Quality & Verification

To verify static analysis and ensure zero linting errors across the codebase, execute:

```bash
flutter analyze
```

To execute unit and widget tests:

```bash
flutter test
```
