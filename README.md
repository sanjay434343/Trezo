<div align="center">
  <img src="assets/images/splash.png" alt="Trezo Logo" width="460" style="border-radius: 20%; margin-bottom: 30px; box-shadow: 0 4px 15px rgba(255, 107, 53, 0.4);"/>



  **Your premium, offline-first personal asset & warranty tracker.**

  <p>
    <a href="#bulb-what-it-solves">What it Solves</a> •
    <a href="#sparkles-features">Features</a> •
    <a href="#camera-screenshots">Screenshots</a> •
    <a href="#rocket-getting-started">Getting Started</a> •
    <a href="#shield-privacy--security">Privacy</a>
  </p>
</div>

---

**Trezo completely rethinks how you manage your most valuable purchases.** Designed with a sleek, high-end dark aesthetic (`#161616` surfaces with `#FF6B35` neon orange accents), Trezo delivers a "wow" experience through fluid animations, premium squircle interfaces, and an uncompromising focus on user privacy.

## :bulb: What it Solves

We all own valuable items—laptops, smart appliances, expensive furniture, and premium gadgets. But when something breaks, finding the receipt or knowing if it's still under warranty is usually a nightmare of digging through email folders, searching physical shoeboxes, or dealing with outdated spreadsheets.

**The result? You pay for repairs that should have been free.**

Trezo solves this instantly by providing a unified, premium, on-device vault for all your assets.

### The Trezo Advantage:
*   **Stop Missing Free Repairs:** We've all missed a warranty window by just a few days. Trezo's dynamic visual countdowns and smart notifications ensure you know *exactly* when a warranty is about to expire, saving you hundreds of dollars in repair costs.
*   **End the Paper Chase:** Snap a picture of your receipt, and our on-device Artificial Intelligence instantly extracts the brand, price, and purchase date. Your physical receipts can finally go in the trash.
*   **Total Financial Clarity:** See the total value of all your active assets at a glance, beautifully organized in a premium dashboard.
*   **Uncompromising Privacy:** Unlike other finance or tracking apps, Trezo **never** harvests your purchase data. Your vault stays 100% offline, securely encrypted on your phone.

## :sparkles: Features

*   :lock: **Offline-First Vault:** Your assets, receipts, and notes are stored exclusively on your device. Only your basic authentication info (name and email) ever touches the cloud. What's yours, stays yours.
*   :mag_right: **Smart AI Receipt Scanner:** Don't type data manually. Just point your camera at an invoice, and our on-device Machine Learning instantly extracts the critical details like magic.
*   :chart_with_upwards_trend: **Dynamic Visual Analytics:** Instantly gauge your coverage with real-time circular progress rings that visually track exactly how many days of warranty you have remaining.
*   :bell: **Intelligent Reminders:** Never miss a deadline. Get automated local push notifications 1 month, 1 week, and 1 day before an asset's warranty expires. Need custom reminders? You can set those too.
*   :art: **Unrivaled UI/UX:** Built for those who appreciate design. Experience incredibly smooth iOS-style continuous curves, fluid entry animations, glassmorphic elements, and the highly legible Libre Baskerville typeface.
*   :key: **Biometric App Lock:** Your purchases are your business. Secure your entire Trezo inventory behind Face ID or fingerprint authentication for ultimate peace of mind.

## :camera: Screenshots

<div align="center">
  <table style="border-collapse: collapse; border: none;">
    <tr>
      <td align="center"><b>The Dashboard</b></td>
      <td align="center"><b>Asset Details</b></td>
      <td align="center"><b>Smart Scanner</b></td>
    </tr>
    <tr>
      <td>
        <img src="assets/screenshots/home.png" alt="Home Screen" width="250"/>
      </td>
      <td>
        <img src="assets/screenshots/details.png" alt="Asset Details" width="250"/>
      </td>
      <td>
        <img src="assets/screenshots/scan.png" alt="Smart Scanner" width="250"/>
      </td>
    </tr>
  </table>
  <p><i>(Place your actual screenshots into the <code>assets/screenshots/</code> folder to display them here!)</i></p>
</div>

## :rocket: Getting Started

Follow these instructions to build and run Trezo locally on your machine.

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version 3.11.5 or higher)
*   Android Studio / Xcode
*   A physical device or emulator

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/sanjay434343/Trezo.git
    cd trezo
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Generate Database Files**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

## :shield: Privacy & Security

Trezo was engineered from the ground up to respect user privacy:
*   **Zero Cloud Asset Tracking:** We **do not** upload, sync, or store your assets, photos, or notes to any cloud servers. 
*   **Authentication Only:** Firebase is used strictly for secure authentication (Email/Google).
*   **On-Device Processing:** All OCR scanning happens locally on your phone's processor. No images are ever sent to external APIs for processing.

---

<div align="center">
  <b>Designed and Engineered with ❤️</b><br>
  <a href="docs/index.html">View Privacy Policy</a> | <a href="docs/terms.html">View Terms & Conditions</a>
</div>
