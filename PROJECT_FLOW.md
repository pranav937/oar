# JadeEd Smart Registration System (OTR Model)
## Project Documentation & User Flow

### 1. Project Overview}/api/ora/candidates/forgot-password 
The **OTR Model** (One-Time Registration) is a premium recruitment and candidate management mobile application designed for the **JadeEd Smart Registration System**. It allows candidates to create a unified profile, upload documents, and apply for multiple recruitment positions seamlessly.

---

### 2. Application User Flow

#### Phase 1: Authentication & Onboarding
1.  **Splash Screen**: High-impact brand introduction with animated logo.
2.  **Login Page**: Secure entry using Username/Email and Password. Includes background decorative elements and glassmorphism cards.
3.  **Registration**: Multi-step flow for new candidates to join the platform.
4.  **OTP Verification**: 6-digit security code verification for account activation.

#### Phase 2: Candidate Dashboard
The **Command Centre** of the app, providing:
*   **Profile Snapshot**: Candidate name, ID, and photo.
*   **Progress Visualization**: A real-time tracking bar showing profile completion percentage.
*   **Quick Stats**: Total applications and pending actions.
*   **Module Grid**:
    *   **Bio Data**: Personal information management.
    *   **Address Details**: Permanent and correspondence address tracking.
    *   **Upload Documents**: Centralized document vault (Aadhaar, Certificates, etc.).
    *   **Account Status**: Current verification and registration standing.

#### Phase 3: Recruitment & Application
1.  **New Openings**: A searchable list of all active job vacancies with detailed requirement cards.
2.  **Job Details**: Deep-dive into specific vacancies (Pay scale, Age limit, Vacancy distribution).
3.  **Apply Now**: Multi-step application wizard (Eligibility -> Preferences -> Evidence -> Settlement).
4.  **My Applications**: History of applied positions with real-time status tracking (Submitted, Approved, Rejected).
5.  **Payment Gateway**: Secure online settlement for application fees.

---

### 3. Design Standards (The "Premium" Look)
The application follows a strictly defined **Premium Design Language**:

*   **Color Palette**: 
    *   `Primary Blue`: #0F172A (Dark Navy) for authority.
    *   `Vibrant Blue`: #2563EB for primary actions.
    *   `Background`: #F8FAFC (Soft Greyish White).
*   **Typography**: Using **Roboto** with heavy weights (w900) for headers to create a "SaaS-like" professional feel.
*   **Visual Elements**:
    *   `Gradients`: Used in profile cards and high-impact buttons.
    *   `Shadows`: Stratified shadows (Soft, Card, Intense) for depth.
    *   `Corner Radius`: Consistent 20px - 24px rounded corners for a modern look.
*   **Interactivity**: Smooth transitions and loading states (SpinKit) to enhance user experience.

---

### 4. Technical Architecture
*   **Framework**: Flutter (Dart)
*   **State Management**: StatefulWidgets with centralized `ApiService`.
*   **Theme Management**: `OtrTheme` class in `lib/theme/otr_theme.dart` for global styling.
*   **Data Source**: REST API integration with JSON data models.
*   **Assets**: SVG-based iconography and logos for crisp rendering on all screen sizes.

---

### 5. Proper Visualization Features
*   **Adaptive Layout**: Auto-wrapping text and flexible grids for various mobile resolutions.
*   **Status Badges**: Color-coded badges (Green for Success, Red for Error, Orange for Pending).
*   **Descriptive Naming**: Professional terminology used across all labels (e.g., "Documentation" instead of "Files").

---
*Created for: JadeEd Smart Registration System*  
*Last Updated: April 2026*
