# JBR-Pharmica — Clinical Reference Mobile Prototype

A high-performance mobile clinical reference prototype developed with **Flutter** for healthcare professionals to search, review, and navigate clinical guidelines, disease management rules, and antibiotic treatment recommendations seamlessly across online and offline environments.

---

## 📌 Integrated Features & Key Accomplishments

- I've integrated a "Search screen"
- I've integrated a "Disease detail screen"
- I've integrated an "Antibiotic detail screen"
- I've integrated an "Offline status banner"
- I've integrated a "Search result tile"
- I've integrated a "Clinical API service"
- I've integrated a "Custom Dio client"
- I've integrated a "Network checker"
- I've integrated an "SQLite database helper"
- I've integrated an "Offline local data source"
- I've integrated a "Two-way SQL join query"
- I've integrated an "Offline-first repository"
- I've integrated a "Reactive GetX controller"
- I've integrated a "Dependency injection binding"
- I've integrated a "Named navigation system"
- I've integrated a "Custom app theme"
- I've integrated a "Disease data model"
- I've integrated an "Antibiotic data model"
- I've integrated a "Recommendation model"

---

## 🏛️ 1. Architecture

This project strictly follows **Feature-First Clean Architecture** principles to enforce separation of concerns, maintainability, and testability.

```
lib/
├── core/                   # Shared infrastructure & utilities
│   ├── bindings/           # Initial global bindings
│   ├── database/           # SQLite database helper & schema definitions
│   ├── network/            # Dio HTTP client, interceptors & network info
│   ├── routes/             # AppPages & AppRoutes configuration
│   └── theme/              # Custom Teal medical design system & typography
├── features/
│   └── clinical/           # Clinical Reference Feature
│       ├── data/           # Models, Data Sources & Repository Implementation
│       │   ├── datasources/# Remote API & Local SQLite Data Sources
│       │   ├── models/     # JSON & Map serializable models
│       │   └── repositories/# Offline-first repository implementation
│       ├── domain/         # Core Pure Entities & Repository Interfaces
│       │   ├── entities/   # Disease, Antibiotic, Recommendation entities
│       │   └── repositories/# Abstract repository contracts
│       └── presentation/   # UI Layer (GetX Controllers, Widgets & Pages)
│           ├── bindings/   # GetX lazy injection bindings
│           ├── controllers/# Reactive state & search logic
│           ├── pages/      # Search, Disease Detail & Antibiotic Detail pages
│           └── widgets/    # Status banners & custom result tiles
└── main.dart               # Application entry point
```

### Data Flow Architecture:
`UI (View)` ➔ `GetX Controller` ➔ `Clinical Repository` ➔ `Local SQLite Data Source` / `Remote API Data Source`

---

## 💾 2. Local Database Choice & Schema

### Technology Selected: **SQLite (`sqflite`)**

### Why SQLite was chosen:
1. **Relational Integrity**: The clinical dataset requires a **Many-to-Many Relationship** between Diseases and Antibiotics through Treatment Recommendations. SQLite natively supports Foreign Key constraints (`FOREIGN KEY`) and relational integrity.
2. **Powerful SQL JOIN Queries**: Enables instant two-way query performance (Disease $\rightarrow$ Antibiotic and Antibiotic $\rightarrow$ Related Diseases) without nested JSON iteration overhead.
3. **Indexing & High Performance**: Indexed columns (`idx_diseases_name`, `idx_recs_disease`, `idx_recs_antibiotic`) ensure sub-millisecond search response times even on lower-end devices.

### Schema Design:
- **`diseases`**: `id (PK)`, `name`, `category`, `keywords`
- **`antibiotics`**: `id (PK)`, `name`, `generic_name`
- **`recommendations` (Junction Table)**: `id (PK)`, `disease_id (FK)`, `antibiotic_id (FK)`, `type`, `dose`, `frequency`, `duration`

---

## 🔍 3. Search Approach

The application implements a practical, highly responsive local search engine across multiple fields.

### Searchable Fields:
- Disease Name & Category
- Disease Keywords (e.g., `fever`, `cough`, `lung`)
- Antibiotic Name & Generic Name
- Treatment Recommendation Type (e.g., `First Line`, `Alternative`)

### Search Logic & Ranking:
1. **Debounced Input**: Input text is processed with dynamic reactivity to prevent unnecessary CPU churn during typing.
2. **Case-Insensitive & Partial Matching**: Queries match partial strings across titles and generic names.
3. **Two-Way Relational Lookup**: Searching an antibiotic returns both the medicine record and all clinical conditions it is prescribed for.
4. **Result Category Filtering**: Filter Choice Chips (`All`, `Diseases`, `Antibiotics`) allow immediate scope refinement.

---

## 📡 4. Offline Strategy

The project implements a resilient **Offline-First Strategy**:

1. **Initial Hydration**: On app startup, if internet is connected, structured clinical datasets are fetched from the remote API via Dio and transactionally cached into SQLite.
2. **Network State Monitoring**: `ConnectivityPlus` and `NetworkInfo` monitor network availability in real-time.
3. **Graceful Fallback**: If offline or internet is disconnected, the app seamlessly serves clinical guidelines directly from the local SQLite cache without interrupting the user.
4. **Status Banner Indicator**: A real-time `StatusBannerWidget` alerts the user when operating in offline cached mode.

---

## 🚀 5. Setup & Running Instructions

### Prerequisites:
- Flutter SDK (v3.19.0 or higher)
- Dart SDK (v3.3.0 or higher)
- Android Studio / Xcode for emulators

### Installation Steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/JBR-Pharmica.git
   cd JBR-Pharmica
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

4. **Build Release APK (Optimized Split ABI):**
   ```bash
   flutter build apk --split-per-abi --release
   ```

---

## 🧪 6. Automated Testing

The repository includes automated unit tests covering core search querying logic and repository offline fallback behavior.

### Execute Tests:
```bash
flutter test
```

### Included Tests:
- **Search Test**: Verifies that searching for a keyword (e.g., `"Medicine Alpha"`) returns expected medicine records.
- **Offline Repository Test**: Simulates network unavailability and verifies that locally stored data is successfully retrieved from the SQLite repository.

---

## 🔮 7. Future Improvements Roadmap

1. **Fuzzy Search & Algorithmic Ranking**: Integrate Levenshtein distance or Trigram matching for typo-tolerant medical search.
2. **FTS5 (Full-Text Search) in SQLite**: Upgrade SQLite tables to FTS5 virtual tables for even faster multi-keyword full-text queries.
3. **PDF Guideline Export**: Allow medical professionals to export disease treatment regimens as branded PDF guidelines.
4. **Biometric Authentication**: Secure clinical settings with fingerprint/FaceID login.
5. **Advanced Dark Mode Support**: Full OLED dark mode support for nighttime clinical shift usage.
