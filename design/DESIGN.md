---
name: Proton Echo
colors:
  surface: '#10131b'
  surface-dim: '#10131b'
  surface-bright: '#363941'
  surface-container-lowest: '#0b0e15'
  surface-container-low: '#181c23'
  surface-container: '#1c2027'
  surface-container-high: '#262a32'
  surface-container-highest: '#31353d'
  on-surface: '#e0e2ed'
  on-surface-variant: '#c0c6d6'
  inverse-surface: '#e0e2ed'
  inverse-on-surface: '#2d3038'
  outline: '#8b91a0'
  outline-variant: '#414754'
  surface-tint: '#aac7ff'
  primary: '#aac7ff'
  on-primary: '#003064'
  primary-container: '#3e90ff'
  on-primary-container: '#002957'
  inverse-primary: '#005db8'
  secondary: '#ffb4aa'
  on-secondary: '#690004'
  secondary-container: '#b6040e'
  on-secondary-container: '#ffc3bb'
  tertiary: '#42e355'
  on-tertiary: '#00390a'
  tertiary-container: '#00a82f'
  on-tertiary-container: '#003208'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#aac7ff'
  on-primary-fixed: '#001b3e'
  on-primary-fixed-variant: '#00468d'
  secondary-fixed: '#ffdad5'
  secondary-fixed-dim: '#ffb4aa'
  on-secondary-fixed: '#410001'
  on-secondary-fixed-variant: '#930007'
  tertiary-fixed: '#70ff76'
  tertiary-fixed-dim: '#42e355'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005313'
  background: '#10131b'
  on-background: '#e0e2ed'
  surface-variant: '#31353d'
  background-base: '#1E1E1E'
  background-sidebar: '#252525'
  background-content: '#1A1A1A'
  status-warning: '#FFD60A'
  text-primary: '#FFFFFF'
  text-secondary: '#A1A1A1'
  text-tertiary: '#6E6E6E'
  border-subtle: '#333333'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  mono-timestamp:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  sidebar-width: 260px
  toolbar-height: 52px
  footer-height: 64px
  gutter-md: 1.5rem
  stack-sm: 0.5rem
  stack-md: 1rem
  inset-container: 2rem
---

## Brand & Style

The design system is built for a professional, offline-first transcription utility. It follows a **Corporate / Modern** movement with heavy inspiration from the **native macOS aesthetic**. The primary goal is to evoke a sense of absolute privacy, reliability, and precision.

The visual language emphasizes:
- **Focused Utility:** Every element serves the task of converting audio to text.
- **Mac-Native Continuity:** Leveraging system-like patterns (sidebars, vibrancy, SF Pro) to minimize the learning curve and feel like a high-end system utility.
- **Reliability:** A robust, stable interface that communicates that data is processed locally and securely.
- **Subtle Modernity:** Using depth and translucency to provide a premium feel without distracting from long-form text.

## Colors

The design system uses a **dark mode default** palette to reduce eye strain during long transcription sessions.

- **Primary Blue (#0A84FF):** Used for primary actions, active states, and system-level focus.
- **Recording Red (#FF453A):** Reserved exclusively for active recording states and critical destructive actions (like "Delete").
- **Success Green (#32D74B):** Indicates completed transcriptions, successful imports, and "Ready" statuses.
- **Neutrals:** A tiered system of deep charcoals. The background uses `#1E1E1E`, while sidebars and content areas use subtle shifts in value to create hierarchy without needing heavy borders.

## Typography

The design system utilizes **Inter** (as a high-quality alternative to SF Pro for cross-platform consistency) to maintain a clean, neutral, and highly legible interface.

- **Headlines:** Use tighter letter spacing and semi-bold weights to anchor page sections.
- **Transcription Text:** The `body-lg` role is optimized for readability with a generous `1.6` line height to prevent fatigue during proofreading.
- **Timestamps:** A monospaced font (**JetBrains Mono**) is used for all timeline indicators to ensure numerical alignment as the time increments.
- **Labels:** Small, uppercase labels with increased tracking are used for category headers in the sidebar.

## Layout & Spacing

This design system employs a **Fixed Three-Pane Layout** typical of macOS productivity apps:
1.  **Sidebar (Left):** Navigation and Note Library (260px).
2.  **Detail View (Center):** The primary transcription and editor area.
3.  **Contextual Inspector (Optional/Right):** Settings or metadata (240px).

**Layout Rules:**
- **Margins:** Use a consistent 32px (`2rem`) padding for the main content area to provide breathing room for long-form text.
- **Grid:** Content follows a simple 12-column internal grid for settings and form layouts, but the transcription timeline uses a specific offset (64px) for timestamps.
- **Responsive:** On narrower windows, the sidebar collapses into an icon-only rail or hides behind a "hamburger" menu toggle.

## Elevation & Depth

The system uses **Tonal Layers** combined with **Glassmorphism** to establish hierarchy.

- **Level 0 (Base):** The main window background with a 15% backdrop blur (vibrancy) when over other windows.
- **Level 1 (Sidebar):** Slightly elevated or recessed via color shift to distinguish from the editor.
- **Level 2 (Cards/Modals):** Subtle 1px borders using `border-subtle` and an ambient, low-opacity black shadow (15% opacity, 12px blur) to appear "floating" over the dark UI.
- **Dividers:** Use horizontal lines with 5% opacity to separate transcription segments without breaking the flow of reading.

## Shapes

The shape language is **Rounded**, mirroring the macOS Ventura/Sonoma interface.

- **Standard Elements:** Buttons, input fields, and search bars use a 8px (`0.5rem`) radius.
- **Containers:** Note list items and cards use a 12px (`0.75rem`) or 16px (`1rem`) radius to feel soft and approachable.
- **Pills:** Status badges (e.g., "Completed", "Recording") use full pill-rounding for high-glanceability.

## Components

### Buttons
- **Primary:** Solid `primary_color_hex` with white text.
- **Secondary/Ghost:** Transparent background with a subtle border or light grey hover state.
- **Recording Button:** High-contrast red with a "pulse" animation for the icon when active.

### Sidebar Items
- **Active State:** A subtle highlight using `primary_color_hex` at 15% opacity with a solid 3px vertical "indicator" on the left edge.

### Status Badges
- Small, rounded-pill containers. 
- **Transcribing:** Yellow background (low opacity) with yellow text.
- **Completed:** Green background (low opacity) with green text.

### Timeline Indicators
- Vertical alignment of timestamps in `mono-timestamp` style. 
- A subtle vertical line connects segments to indicate a continuous audio session.

### Input Fields
- Darker than the background (`#151515`), 1px subtle border, and 8px corner radius. Focused state uses a 2px `primary_color_hex` outer glow.

### Cards (Notes)
- Note previews in the sidebar should show a Title, a relative timestamp (e.g., "2 hours ago"), and a 1-line snippet of the transcription.