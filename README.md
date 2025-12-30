# CorpPulse

CorpPulse is a comprehensive, role-based corporate dashboard application built entirely with Flutter. It allows executives, regional managers, and branch users to monitor key financial performance indicators (KPIs) across various regions.

**Note:** This project adheres to a strict "No External Packages" constraint. All UI components, charts, data services, and formatters are implemented using only the core Flutter SDK.

## Project Overview

The application provides a high-level view of financial health, including:
-   **Regular Collection:** Demand vs. Collection.
-   **Bucket Analysis:** 1-30 days and 31-60 days buckets.
-   **NPA Management:** PNPA (Potential Non-Performing Assets) and NPA cases.
-   **Regional Performance:** Ranking and performance categorization (Above/Below Average).

## Key Features

*   **Role-Based Access Control (RBAC):**
    *   **CEO:** View data for all regions and grand totals.
    *   **Regional Manager:** View data only for their assigned region and grand totals.
    *   **Branch User:** Simplified view with key KPI cards.
*   **Dynamic Dashboard:** Real-time (mocked) data generation with complex financial metrics.
*   **Interactive UI:** Custom-built glassmorphism effects, neon glows, and animated transitions.
*   **Detailed Analytics:** Drill-down views for specific regions.

## Architecture & File Structure

The project follows a clean, feature-based directory structure within `lib/`:

```
lib/
├── components/      # Reusable UI widgets (Glass effects, Charts, Cards)
├── models/          # Data models (RegionReportRow, UserSession, Role)
├── services/        # Logic & Data generation (MockDataService)
├── theme/           # App styling (AppTheme, Colors, TextStyles)
├── views/           # Screens and Page Layouts
└── main.dart        # Entry point and Routing
```

### Core Components (`lib/components`)
Since external charting libraries were not allowed, custom widgets were created:
*   `MiniBarChart`: A custom canvas-based bar chart for visual comparisons.
*   `RingGauge`: A custom radial gauge to display percentage completion.
*   `GlassBackground`: Implements the glassmorphism effect using `BackdropFilter`.
*   `NeonCard` & `GlowButton`: Styled containers with shadow and border effects.

### Data Layer (`lib/services` & `lib/models`)
*   **MockDataService:** Generates realistic random financial data, handles sorting, ranking, and computing grand totals. It simulates API latency and caching.
*   **Data Formatting:** A custom `AppTheme.formatNumber` helper replaces the `intl` package for currency formatting (e.g., `1,234,567`).

## UI & Design System

The app features a **Dark Neon** theme designed for high contrast and modern aesthetics.
*   **Background:** Deep black (`#050505`).
*   **Accents:** Neon Cyan, Green, Purple, and Red.
*   **Typography:** 'Roboto' (default) with hierarchy defined in `AppTheme`.

## Setup & Running

1.  **Prerequisites:** Ensure you have the Flutter SDK installed (`>=3.2.0 <4.0.0`).
2.  **Clone the repository.**
3.  **Run the app:**
    ```bash
    flutter run
    ```

## Development Constraints

This project serves as a demonstration of what is possible with **Pure Flutter**.
-   **No `intl`:** Currency and number formatting is handwritten.
-   **No `fl_chart`:** Charts are built using `CustomPaint` or basic container composition.
-   **No `google_fonts`:** Uses system fonts or local assets (if added).
-   **No State Management Libraries:** Uses vanilla `setState` and simple passing of data models.
