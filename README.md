# My Book Your Book

A Flutter-based mobile application facilitating book exchanges between university students. This project demonstrates the practical application of modern mobile development concepts, cloud services, and real-time communication.

## Project Overview

### Purpose
My Book Your Book serves as a platform where university students can:
- List books they want to share
- Browse available books
- Make exchange requests
- Chat with other users
- Conduct safe in-person exchanges

### Technical Stack
- **Frontend**: Flutter/Dart
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Security Rules
- **State Management**: Flutter's built-in state management
- **Real-time Updates**: Firebase streams

## Key Features

### Authentication
- Email-based authentication
- Email verification
- Secure password handling
- Gender-based default avatars

### Book Management
- Create book listings
- Browse available books
- Department-based organization
- Real-time updates

### Request System
- Send exchange requests
- Accept/reject requests
- Request status tracking
- Real-time notifications

### Chat System
- Real-time messaging
- User presence indicators
- Message persistence
- Chat history

### Safety Features
- Comprehensive rules page
- Public meeting recommendations
- User verification
- Secure data handling

## Technical Implementation

### Architecture
The application follows a clean architecture approach with:
- Separation of concerns
- Component-based design
- Service-based data handling
- Real-time data synchronization

### Security
- Firebase Authentication integration
- Secure Firestore rules
- Data validation
- Safe state management

### Database Design
```
users/
  ├─ uid/
  │  ├─ email
  │  ├─ studentId
  │  ├─ gender
  │  └─ profilePic

posts/
  ├─ postId/
  │  ├─ bookName
  │  ├─ department
  │  ├─ ownerId
  │  └─ requests/
  │     └─ requestId/
  │        ├─ requesterId
  │        ├─ status
  │        └─ timestamp

chats/
  ├─ chatId/
  │  ├─ participants
  │  ├─ lastMessage
  │  └─ messages/
  │     └─ messageId/
  │        ├─ senderId
  │        ├─ text
  │        └─ timestamp
```

## Development Approach

This project was developed using a modern approach to software engineering, leveraging AI tools (primarily GitHub Copilot) for code generation while maintaining focus on:

1. **Architecture Design**: Personally designed the system architecture and data flow
2. **Problem Solving**: Identified and implemented solutions for complex features
3. **Code Review**: Carefully reviewed and understood all generated code
4. **Testing**: Manually tested all features and edge cases
5. **Security**: Implemented and verified security measures
6. **User Experience**: Designed and refined the user interface

### AI Utilization
In the spirit of academic honesty, this project extensively used AI tools for code generation. However, the following aspects were personally handled:
- System architecture design
- Database schema design
- Feature specification
- Security implementation
- Code review and validation
- Bug fixing and optimization
- User interface design decisions

This approach reflects modern software development practices where AI tools are increasingly used as development accelerators while maintaining human oversight for critical decisions and architecture.

## Installation and Setup

1. Clone the repository
```bash
git clone https://github.com/911devsacc/my-book-your-book.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a new Firebase project
   - Add Android/iOS apps
   - Download and add configuration files
   - Enable Email Authentication
   - Set up Firestore

4. Run the application
```bash
flutter run
```

## Future Enhancements
- Book categories and filtering
- User ratings and reviews
- Push notifications
- Image upload capability
- Offline support
- Advanced chat features

## Academic Context

This project demonstrates understanding of:
- Mobile application development
- Cloud service integration
- Real-time data handling
- Security implementation
- User interface design
- Modern development practices

While AI tools were used for code generation, the project showcases ability to:
- Design system architecture
- Make technical decisions
- Implement security measures
- Create user-friendly interfaces
- Solve real-world problems
- Integrate complex systems

## License
MIT License

## Acknowledgments
- Flutter and Firebase documentation
- GitHub Copilot
- Stack Overflow community
