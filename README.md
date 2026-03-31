# ImpactForge: Democratizing Social Entrepreneurship 🚀

**website link** https://codenyx-deployment.onrender.com/

**Validate Impact. Forge Transparency. Build the Future.**

ImpactForge is a high-performance, AI-driven platform built for a world where social impact ideas are often lost due to a lack of strategic validation, funding transparency, and technical resources. We bridge the gap between visionary founders, risk-averse investors, and a global pool of developer talent.

---

## 🌟 The Core Pillars of ImpactForge

ImpactForge operates as a unified, three-sided ecosystem:

### 1. The Startup Sandbox (Founders)
- **Vicharane AI Engine:** A world-class, strict AI evaluator that stress-tests social venture ideas.
- **Micro-Budgeting:** Generates 80/20 budget roadmaps, simulating high-impact growth with minimal capital.
- **Validation Score:** Founders receive an ESG-aligned validation score required to list on the Investor Feed.

### 2. The De-Risked Deal Flow (Investors)
- **Verified Pitching:** Only AI-validated startups appear on the dashboard, reducing DD (Due Diligence) time by 90%.
- **Milestone Escrow:** Funding is locked into milestones and only released when the startup completes its Vicharane roadmap.
- **Glassmorphism Analytics:** Premium UI for tracking social impact yield alongside financial progress.

### 3. The Tech-For-Good Gig Board (Developers)
- **Bounty System:** Investment capital is converted into trackable bounties for open-source and freelance developers.
- **Impact Rewards:** Developers contribute to world-changing projects and get paid instantly upon milestone validation.
- **Web3-Inspired UI:** A gamified experience for engineers building the infrastructure of the future.

---

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Web, Android, iOS)
- **Backend:** [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore)
- **AI Engine:** [OpenRouter API](https://openrouter.ai/) (Gemini 2.0 Flash Integration)
- **Design System:** Custom Material 3 Design with Glassmorphism and Dynamic Light/Dark Mode.
- **Deployment:** [Render](https://render.com/) (via Dockerized Nginx)

---

## 🚀 Getting Started

### 🔓 Demo Login Mode
For the quickest way to explore the platform, use our built-in **Demo Buttons** on the starting screen. This bypasses real-time auth for a zero-friction experience:
- **Founder Demo:** Pre-configured with a startup founder profile.
- **Investor Demo:** Pre-configured with a VC dashboard view.
- **Developer Demo:** Pre-configured with the Gig Board access.

### 🔨 Manual Setup (Local Development)

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/vineelvanjari/codenyx_49.git
    cd codenyx_49
    ```

2.  **Environment Variables:**
    Create a `.env` file in the root directory and add your OpenRouter API Key:
    ```env
    OPEN_ROUTER_KEY=your_openrouter_api_key_here
    ```

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the Application:**
    - For Chrome: `flutter run -d chrome`
    - For Android: `flutter run -d <device_id>`

---

## 🐳 Deployment to Render

This project includes a `Dockerfile` and `nginx.conf` for instant deployment to Render:
1. Connect your GitHub repository to [Render](https://render.com/).
2. Select **Web Service**.
3. Render will auto-detect the `Dockerfile` and build the application.

---

## 🤝 Open Source & Contributions

ImpactForge is built on the belief that transparency is the ultimate driver of social good. We welcome contributors from all backgrounds!

### How to Contribute:
1.  **Fork** the repo and create your branch (`git checkout -b feature/NewAwesomeFeature`).
2.  **Commit** your changes (`git commit -m 'Add some NewAwesomeFeature'`).
3.  **Push** to the branch (`git push origin feature/NewAwesomeFeature`).
4.  **Open a Pull Request**.

### Project Structure:
- `lib/config/`: Theme, Typography, and Routing.
- `lib/core/`: Models, API services, and the AI Engine.
- `lib/features/`: UI modules for Auth, Founder, Investor, and Developer modules.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

*Built with ❤️ for a better tomorrow.*
