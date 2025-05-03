# SetMate
SetMate is your reliable gym buddy, designed to make tracking your workouts effortless and motivating. Whether you're hitting the weights, targeting specific muscle groups, or following a customized fitness plan, SetMate helps you record every set, rep, and weight with precision.

⚠️ This code is provided for academic evaluation purposes only. 
All rights reserved. You may not copy, reuse, or modify any part of this repository without explicit permission.

## 📦 How to Run This Project

### 🖥️ Backend (Spring Boot)

#### ✅ Requirements
- Java 17+
- Maven
- MySQL

#### Run the backend:
   ```bash
   cd cd setmate-backend/
   mvn spring-boot:run
   ```
if you use IntelliJ, you can Go directly to SetmateBackendApplication.java and click the run button

---

### 📱 Frontend (Flutter)

#### ✅ Requirements
- Flutter SDK
- iOS emulator or physical device

#### ⚙️ Configuration

1. Please use in ios Emulator
   
  
2. Install dependencies:
   ```bash
   cd front_end_flutter
   cd setmate_app
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## 🔐 Authentication (JWT)

- Register:
  ```
  POST /api/users/register
  {
    "username": "your_name",
    "email": "your_email",
    "password": "your_password"
  }
  ```

- Login:
  ```
  POST /api/users/login
  {
    "email": "your_email",
    "password": "your_password"
  }
  ```

- Backend will return a JWT token:
  ```
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

- Use the token in subsequent requests:
  ```
  Authorization: Bearer <token>
  ```

---

## ⚠️ Notes

- Backend must be running before starting the frontend.
- If testing from a physical device, change BASE_URL to your host machine's IP.
- CORS should be enabled in Spring Boot for cross-origin requests.
- If using Docker or a remote DB, update host and firewall settings accordingly.

---

## 💡 Features

- JWT-based authentication
- CRUD for training sessions
- Batch management of exercises linked to sessions
- Visual summaries (e.g., duration charts)
- Goal setting and profile display
- Secure data handling via ORM and prepared statements

---

## 📄 License

```text
Copyright (c) 2025 by the Author.

This code is proprietary and confidential. No permission is granted to copy, distribute, or modify any part of this code without explicit written consent from the author.
```

