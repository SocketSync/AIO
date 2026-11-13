# FinWise Firebase Cloud Firestore Architecture & Security Rules

## 1. Firestore Data Collections

### `users/{userId}`
User profile document:
- `email`: string (Gmail)
- `displayName`: string
- `avatarUrl`: string (optional)
- `phone`: string (e.g. "+60 12-345 6789")
- `occupation`: string (e.g. "Senior Software Engineer")
- `currency`: string (default "RM")
- `monthlyBudget`: number (default 2500.0)
- `createdAt`: timestamp
- `updatedAt`: timestamp

### `users/{userId}/transactions/{transactionId}`
Sub-collection containing user-scoped transactions:
- `title`: string
- `amount`: number
- `type`: string ("expense" | "income")
- `categoryId`: string ("food_dining", "transportation", etc.)
- `categoryName`: string
- `categoryColorHex`: string
- `categoryIcon`: string
- `transactionDate`: timestamp
- `notes`: string (optional)
- `createdAt`: timestamp
- `updatedAt`: timestamp

---

## 2. Firebase Security Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Profiles
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // Transactions sub-collection
      match /transactions/{transactionId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

