<div align="center">

# 🌙 Takwa Monorepo

**A Premium Islamic Ecosystem — Mobile & Web**

_Hold yourselves accountable before you are held accountable._

[![Melos](https://img.shields.io/badge/Managed%20by-Melos-0175C2.svg)](https://melos.invertase.dev)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![Next.js](https://img.shields.io/badge/Web-Next.js-black?logo=next.js)](https://nextjs.org)
[![License](https://img.shields.io/badge/License-MIT-gold)](LICENSE)

</div>

---

## 📂 Project Structure

This monorepo manages all Takwa-related applications and shared libraries:

- **[`apps/mobile`](apps/mobile)**: The flagship Flutter mobile application.
- **[`apps/web`](apps/web)**: The Next.js web application companion.
- **[`packages/`](packages)**: (Planned) Shared domain logic and UI components.

---

## 🚀 Quick Start

### 1. Prerequisites

- **Flutter SDK**: [Install](https://docs.flutter.dev/get-started/install)
- **Node.js**: [Install](https://nodejs.org/)
- **Melos**: Install globally via `dart pub global activate melos`.

### 2. Setup Entire Environment

From the root directory, run:

```bash
# Bootstrap Flutter packages and fetch dependencies
npm run mobile:bootstrap
```

### 3. Run Applications

| App        | Development Command             |
| ---------- | ------------------------------- |
| **Mobile** | `cd apps/mobile && flutter run` |
| **Web**    | `npm run web:dev`               |

---

## 🛠️ Monorepo Commands

| Command                    | Description                                          |
| -------------------------- | ---------------------------------------------------- |
| `npm run mobile:bootstrap` | Uses Melos to bootstrap all Flutter packages.        |
| `npm run mobile:clean`     | Cleans all Flutter build artifacts.                  |
| `npm run web:dev`          | Starts the Next.js dev server for the web workspace. |
| `npm run web:build`        | Build the web app for production.                    |

---

## 🏗️ Technical Stack

- **Mobile**: Flutter, Riverpod, Drift (SQLite), Adhan API.
- **Web**: Next.js 16, React 19, TypeScript, Tailwind CSS.
- **Management**: Melos, NPM Workspaces.

---

<div align="center">

_"حاسبوا أنفسكم قبل أن تُحاسبوا"_
Made with ❤️ for the Muslim community

</div>
