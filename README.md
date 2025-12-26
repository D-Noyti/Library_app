# Library App – Flutter Mobile Application

## 1. Project Overview

Library App is a mobile application developed using Flutter that aims to provide a complete digital library management system. The application allows users to search for books, manage reservations, and read books directly within the app. It integrates modern mobile development technologies and follows a structured and modular architecture.

This project was developed in an academic context to apply concepts related to mobile application development, API integration, state management, and local data persistence.

---

## 2. Objectives

The main objectives of this project are:
- To design and develop a functional mobile application using Flutter
- To implement secure user authentication
- To integrate an external REST API for real-time data retrieval
- To manage local data storage and caching
- To apply clean architecture and state management principles
- To provide a user-friendly and responsive interface

---

## 3. Technologies and Tools

- **Framework**: Flutter (Dart)
- **Authentication**: Firebase Authentication (Email/Password)
- **External API**: Google Books API
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **Navigation**: Navigator 2.0
- **UI Design**: Material Design 3

---

## 4. Application Features

### 4.1 Authentication
- User registration with email and password
- User login and logout
- Persistent authentication sessions
- Error handling for authentication failures

### 4.2 Book Search
- Real-time search using Google Books API
- Pagination with infinite scrolling
- Filtering by categories
- Local caching for improved performance

### 4.3 Reservation Management
- Book reservation
- Reservation cancellation and modification
- Book return management
- Reservation history
- Personal statistics related to borrowed and returned books

### 4.4 Book Reader
- Integrated book reading interface
- Vertical page navigation using PageView
- Smooth and intuitive reading experience

---

## 5. Project Architecture

The project follows a layered and modular architecture to ensure maintainability and scalability.


- **Models**: Data structures (Book, Reservation, User)
- **Providers**: State management and business logic
- **Services**: API calls, Firebase services, and local storage
- **Pages**: Application screens
- **Widgets**: Reusable UI components
- **Utils**: Constants, validators, and helper functions

---

## 6. Data Management

- Remote data is retrieved from the Google Books API
- Local persistence is handled using SQLite
- SharedPreferences is used for caching and storing user preferences
- Sensitive data such as API keys are managed using environment variables

---

## 7. Security Considerations

- Firebase authentication ensures secure access control
- Sensitive configuration files are excluded using `.gitignore`
- API keys are not stored directly in the source code
- Environment variables are used to protect confidential data

---

## 8. Conclusion

Library App demonstrates the practical implementation of mobile application development concepts using Flutter. The project highlights the integration of external APIs, secure authentication, local data storage, and modern UI design. It serves as a solid foundation for further enhancements such as cloud synchronization, role-based access, or advanced recommendation systems.

---

## 9. Author

**Hamza**  
Flutter Mobile Application Development Project


