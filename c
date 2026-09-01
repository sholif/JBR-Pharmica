
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
