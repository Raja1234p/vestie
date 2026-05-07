# Vestie Detailed API Documentation (Up to Week 4)

This document provides an exhaustive reference for the Vestie API, detailing exact request payloads, response bodies, and error scenarios for every endpoint to facilitate full mobile application integration.

**Base URL:** `/api/v1`
**Content-Type:** `application/json`

---

## 1. Authentication (`/auth`)
No `Authorization` header required unless specified.

### 1.1. Register Account
**`POST /auth/register`**
Creates a new user account. Returns user ID and requires email verification.

**Request Body:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "StrongPassword123!",
  "confirmPassword": "StrongPassword123!"
}
```

**Success Response (201 Created):**
```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "requiresEmailVerification": true
}
```

**Error Responses:**
- **400 Bad Request** (Validation Failure):
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": { "Password": [ "Password must be at least 8 characters." ] }
}
```
- **409 Conflict** (Email already exists):
```json
{
  "title": "Registration failed",
  "detail": "A user with this email already exists."
}
```

---

### 1.2. Verify Email
**`POST /auth/verify-email`**
Verifies OTP.

**Request Body:**
```json
{
  "email": "john@example.com",
  "code": "123456"
}
```

**Success Response (200 OK):**
```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "tokens": {
    "accessToken": "ey...",
    "refreshToken": "ey...",
    "expiresAtUtc": "2026-05-07T12:00:00Z"
  }
}
```

**Error Responses:**
- **400 Bad Request** (Invalid Code):
```json
{
  "title": "Verification failed",
  "detail": "Invalid or expired verification code."
}
```

---

### 1.3. Resend Verification Code
**`POST /auth/resend-code`**

**Request Body:**
```json
{
  "email": "john@example.com"
}
```

**Success Response (200 OK):**
```json
{
  "message": "If your email is registered and unverified, a new code has been sent."
}
```

**Error Responses:**
- **400 Bad Request** (Validation Error on email format).

---

### 1.4. Login
**`POST /auth/login`**

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "StrongPassword123!",
  "deviceName": "iPhone 15",
  "ipAddress": "192.168.1.1"
}
```

**Success Response (200 OK):**
```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "tokens": {
    "accessToken": "ey...",
    "refreshToken": "ey...",
    "expiresAtUtc": "2026-05-07T12:00:00Z"
  }
}
```

**Error Responses:**
- **400 Bad Request** (Email not verified):
```json
{
  "title": "Email not verified",
  "detail": "You must verify your email before logging in."
}
```
- **401 Unauthorized** (Invalid credentials):
```json
{
  "title": "Authentication failed",
  "detail": "Invalid email or password."
}
```

---

### 1.5. Refresh Token
**`POST /auth/refresh`**

**Request Body:**
```json
{
  "refreshToken": "current-refresh-token",
  "deviceName": "iPhone 15",
  "ipAddress": "192.168.1.1"
}
```

**Success Response (200 OK):**
```json
{
  "accessToken": "new-access-token",
  "refreshToken": "new-refresh-token",
  "expiresAtUtc": "2026-05-14T12:00:00Z"
}
```

**Error Responses:**
- **401 Unauthorized** (Token invalid/expired):
```json
{
  "title": "Token refresh failed",
  "detail": "Invalid or expired refresh token."
}
```

---

### 1.6. Forgot Password
**`POST /auth/forgot-password`**

**Request Body:**
```json
{
  "email": "john@example.com"
}
```

**Success Response (200 OK):**
```json
{
  "message": "If an account with that email exists, a reset code has been sent."
}
```

---

### 1.7. Reset Password
**`POST /auth/reset-password`**

**Request Body:**
```json
{
  "email": "john@example.com",
  "code": "123456",
  "newPassword": "NewPassword123!",
  "confirmNewPassword": "NewPassword123!"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Password has been reset. Please log in with your new password."
}
```

**Error Responses:**
- **400 Bad Request** (Invalid Code):
```json
{
  "title": "Reset failed",
  "detail": "Invalid or expired reset code."
}
```

---

### 1.8. External Login (Google/Apple)
**`POST /auth/google`** or **`POST /auth/apple`**

**Request Body:**
```json
{
  "idToken": "google-or-apple-jwt-token",
  "deviceName": "iPhone",
  "ipAddress": "1.1.1.1"
}
```

**Success Response (200 OK):**
```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "tokens": {
    "accessToken": "ey...",
    "refreshToken": "ey...",
    "expiresAtUtc": "2026-05-07T12:00:00Z"
  }
}
```

**Error Responses:**
- **401 Unauthorized**:
```json
{
  "title": "Google login failed",
  "detail": "Invalid ID token."
}
```

---

### 1.9. Logout
**`POST /auth/logout`**
*Requires `Authorization: Bearer <token>`*

**Request Body:** (Plain string)
```json
"your-refresh-token-here"
```

**Success Response (200 OK):**
```json
{
  "message": "Logged out."
}
```

**Error Responses:**
- **401 Unauthorized** (If access token is missing/invalid).

---

## 2. Users (`/users`)
*Requires `Authorization: Bearer <token>`*

### 2.1. Get My Profile
**`GET /users/me`**

**Success Response (200 OK):**
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "email": "john@example.com",
  "userName": "johndoe",
  "firstName": "John",
  "lastName": "Doe",
  "photoUrl": "https://example.com/photo.jpg",
  "isEmailVerified": true,
  "status": "Active",
  "riskAcceptedAtUtc": "2026-05-01T10:00:00Z",
  "roles": ["User"]
}
```

**Error Responses:**
- **401 Unauthorized**
- **404 Not Found** (If user record is missing).

---

### 2.2. Update My Profile
**`PUT /users/me`**

**Request Body:** (Partial update, null fields are ignored)
```json
{
  "firstName": "Johnny",
  "lastName": "Doe",
  "userName": "johnnyD",
  "photoUrl": "https://example.com/new-photo.jpg"
}
```

**Success Response (200 OK):**
Returns the updated full profile object (same as `GET /users/me`).

**Error Responses:**
- **409 Conflict** (Username taken):
```json
{
  "title": "Update failed",
  "detail": "Username is already taken."
}
```

---

### 2.3. Get Risk Disclaimer
**`GET /users/me/risk-disclaimer`**

**Success Response (200 OK):**
```json
{
  "version": "1.0",
  "guidelines": [
    "I understand my capital is at risk.",
    "I understand Vestie does not guarantee returns."
  ],
  "accepted": false
}
```

---

### 2.4. Accept Risk Disclaimer
**`POST /users/me/risk-disclaimer`**

**Request Body:**
```json
{
  "disclaimerVersion": "1.0",
  "ipAddress": "192.168.1.1"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Risk disclaimer accepted."
}
```

---

## 3. Projects (`/projects`)
*Requires `Authorization: Bearer <token>`*

### 3.1. Create Draft Project
**`POST /projects`**

**Request Body:**
```json
{
  "name": "Community Farm Fund",
  "description": "Funding for a new tractor.",
  "type": "Community",
  "visibility": "Public",
  "targetAmount": 5000.0,
  "maxMembers": 20,
  "endsAtUtc": "2026-12-31T23:59:59Z",
  "contributionDeadlineUtc": "2026-06-30T23:59:59Z",
  "borrowingEnabled": true,
  "suggestedContributionAmount": 250.0,
  "joinApprovalRequired": true,
  "roiPercentage": 5.0,
  "repaymentWindowDays": 60,
  "repaymentGraceDays": 7,
  "penaltyPercentage": 2.0,
  "minimumContributionAmount": 50.0,
  "contributionsAreNonRefundable": true
}
```

**Success Response (201 Created):**
```json
{
  "id": "project-guid",
  "name": "Community Farm Fund",
  "description": "Funding for a new tractor.",
  "type": "Community",
  "visibility": "Public",
  "state": "Draft",
  "targetAmount": 5000.0,
  "maxMembers": 20,
  "endsAtUtc": "2026-12-31T23:59:59Z",
  "launchedAtUtc": null,
  "borrowingEnabled": true,
  "suggestedContributionAmount": 250.0,
  "createdUtc": "2026-05-07T10:00:00Z"
}
```

**Error Responses:**
- **400 Bad Request** (Invalid project data):
```json
{
  "title": "Invalid project",
  "detail": "Target amount must be greater than zero."
}
```

---

### 3.2. List Projects
**`GET /projects?scope=mine`** OR **`GET /projects?scope=discover`**

**Success Response (200 OK):**
```json
[
  {
    "id": "project-guid",
    "name": "Community Farm Fund",
    "description": "Funding for a new tractor.",
    "type": "Community",
    "visibility": "Public",
    "state": "Active",
    "targetAmount": 5000.0,
    "maxMembers": 20,
    "endsAtUtc": "2026-12-31T23:59:59Z",
    "launchedAtUtc": "2026-05-01T10:00:00Z",
    "borrowingEnabled": true,
    "suggestedContributionAmount": 250.0,
    "createdUtc": "2026-04-20T10:00:00Z"
  }
]
```

**Error Responses:**
- **400 Bad Request**:
```json
{
  "title": "Invalid scope",
  "detail": "Use scope=mine or scope=discover."
}
```

---

### 3.3. Get Project Detail
**`GET /projects/{id}`**

**Success Response (200 OK):**
```json
{
  "project": {
    "id": "project-guid",
    "name": "Community Farm Fund",
    "description": "Funding for a new tractor.",
    "type": "Community",
    "visibility": "Public",
    "state": "Active",
    "targetAmount": 5000.0,
    "maxMembers": 20,
    "endsAtUtc": "2026-12-31T23:59:59Z",
    "launchedAtUtc": "2026-05-01T10:00:00Z",
    "borrowingEnabled": true,
    "suggestedContributionAmount": 250.0,
    "createdUtc": "2026-04-20T10:00:00Z"
  },
  "rules": {
    "contributionsAreNonRefundable": true,
    "roiPercentage": 5.0,
    "joinApprovalRequired": true,
    "borrowingAllowed": true,
    "successVoteWindowHours": 24,
    "repaymentGraceDays": 7,
    "repaymentWindowDays": 60,
    "penaltyPercentage": 2.0,
    "minimumContributionAmount": 50.0
  },
  "viewerMembership": {
    "membershipId": "membership-guid",
    "userId": "user-guid",
    "userName": "johndoe",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Leader",
    "status": "Active",
    "borrowLimitAmount": 1000.0,
    "isDefaulted": false
  },
  "members": [
    {
      "membershipId": "member2-guid",
      "userId": "user2-guid",
      "userName": "janedoe",
      "firstName": "Jane",
      "lastName": "Doe",
      "role": "Member",
      "status": "Active",
      "borrowLimitAmount": 500.0,
      "isDefaulted": false
    }
  ],
  "invites": [
    {
      "id": "invite-guid",
      "inviteCode": "INV-XYZ123",
      "requiresApproval": true,
      "expiresAtUtc": "2026-06-01T10:00:00Z",
      "maxUses": 10,
      "usedCount": 2
    }
  ]
}
```

**Error Responses:**
- **404 Not Found**

---

### 3.4. Update Project
**`PUT /projects/{id}`**

**Request Body:** (Partial update)
```json
{
  "name": "Updated Farm Fund",
  "targetAmount": 6000.0
}
```

**Success Response (200 OK):**
Returns updated `ProjectSummaryDto` (same structure as 3.1).

**Error Responses:**
- **403 Forbidden** (User is not a Leader/Co-leader)
- **400 Bad Request** (Cannot update active project target amount, etc.):
```json
{
  "title": "Update rejected",
  "detail": "Cannot change target amount once project is active."
}
```

---

### 3.5. Project State Actions
All endpoints below take an empty body (unless specified).
**Success Response (200 OK):** Returns updated `ProjectSummaryDto`, except `Cancel` which returns `204 No Content`.
**Error Responses:** `400 Bad Request` if state transition is invalid, `403 Forbidden` if not authorized.

- **Launch Project**: `POST /projects/{id}/launch`
- **Cancel Project**: `POST /projects/{id}/cancel` (Returns `204`)
- **Complete Successful**: `POST /projects/{id}/complete`

---

### 3.6. Memberships & Invites

#### 3.6.1. Join Project
**`POST /projects/join`**
**Request Body:**
```json
{
  "projectId": "project-guid",
  "inviteCode": "INV-XYZ123"
}
```
**Success Response (200 OK):**
```json
{
  "projectId": "project-guid",
  "membershipId": "membership-guid",
  "status": "PendingApproval",
  "role": "Member"
}
```
**Error Responses:** `400 Bad Request` ("Join rejected: Invite expired").

#### 3.6.2. Create Invite
**`POST /projects/{id}/invites`**
**Request Body:**
```json
{
  "requiresApproval": true,
  "expiresInDays": 30,
  "maxUses": 10
}
```
**Success Response (200 OK):**
```json
{
  "id": "invite-guid",
  "inviteCode": "INV-ABC987",
  "requiresApproval": true,
  "expiresAtUtc": "2026-06-06T10:00:00Z",
  "maxUses": 10,
  "usedCount": 0
}
```

#### 3.6.3. Preview Invite
**`GET /projects/invites/{inviteCode}/preview`**
**Success Response (200 OK):**
```json
{
  "projectId": "project-guid",
  "projectName": "Community Farm Fund",
  "projectType": "Community",
  "visibility": "Public",
  "requiresApproval": true,
  "expiresAtUtc": "2026-06-06T10:00:00Z",
  "isExpired": false,
  "isJoinable": true
}
```

#### 3.6.4. Member Management (Leaders only)
Returns **204 No Content** on success. Errors return **400 Bad Request** or **403 Forbidden**.

- **Approve Membership**: `POST /projects/{id}/memberships/{membershipId}/approve`
- **Reject Membership**: `POST /projects/{id}/memberships/{membershipId}/reject`
- **Assign Co-Leader**: `POST /projects/{id}/members/{userId}/co-leader`
- **Revoke Co-Leader**: `DELETE /projects/{id}/members/{userId}/co-leader`
- **Remove Member**: `DELETE /projects/{id}/members/{userId}`
- **Mark Defaulted**: `POST /projects/{id}/members/{userId}/defaulted`
- **Remove for Non-Repayment**: `POST /projects/{id}/members/{userId}/remove-non-repayment`

#### 3.6.5. Set Borrow Limit
**`PATCH /projects/{id}/members/{userId}/borrow-limit`**
**Request Body:**
```json
{
  "borrowLimitAmount": 1500.0
}
```
**Success Response (204 No Content)**

---

### 3.7. Milestones, Voting & Finance

Returns **200 OK** with `ProjectSummaryDto` on success unless specified. Errors return **400 Bad Request** or **403 Forbidden**.

- **Resolve Goal**: `POST /projects/{id}/goal/resolve`
  **Request Body:** `{ "closeEarly": true }`
- **Extend Deadline**: `POST /projects/{id}/deadline/extend`
  **Request Body:** `{ "newEndsAtUtc": "2026-12-31T23:59:59Z" }`
- **Open Closure Voting**: `POST /projects/{id}/closure-voting/open`
- **Cast Closure Vote**: `POST /projects/{id}/closure-voting/vote`
  **Request Body:** `{ "decision": "Approve" }` (or `"Reject"`)
- **Extend Closure Voting**: `POST /projects/{id}/closure-voting/extend`
  **Request Body:** `{ "additionalHours": 24 }`
- **Finalize Closure Voting**: `POST /projects/{id}/closure-voting/finalize`

#### 3.7.1. Create Borrow Request
**`POST /projects/{id}/borrow-requests`**
**Request Body:**
```json
{
  "requestedAmount": 500.0,
  "reason": "Buying seeds"
}
```
**Success Response (200 OK):**
```json
{
  "id": "request-guid",
  "projectId": "project-guid",
  "requesterMembershipId": "membership-guid",
  "requestedAmount": 500.0,
  "currency": "USD",
  "reason": "Buying seeds",
  "status": "Pending",
  "dueAtUtc": "2026-07-01T10:00:00Z"
}
```

#### 3.7.2. Record External Investment
**`POST /projects/{id}/investment/external`**
**Request Body:**
```json
{
  "amount": 2000.0,
  "provider": "Local Bank",
  "reference": "LOAN-998",
  "notes": "Low interest loan"
}
```
**Success Response (200 OK):**
```json
{
  "id": "investment-guid",
  "projectId": "project-guid",
  "recordedByMembershipId": "membership-guid",
  "amount": 2000.0,
  "currency": "USD",
  "provider": "Local Bank",
  "reference": "LOAN-998",
  "notes": "Low interest loan",
  "investedAtUtc": "2026-05-07T10:00:00Z"
}
```

---

## 4. Ledger Transactions (`/ledger/transactions`)
Internal accounting operations (usually called by backend services, but exposed here if needed).

**`POST /ledger/transactions`**

**Request Body:**
```json
{
  "source": "ProjectFund",
  "reference": "TRX-12345",
  "description": "Funding project",
  "projectId": "project-guid",
  "userId": "user-guid",
  "occurredAtUtc": "2026-05-07T10:00:00Z",
  "lines": [
    {
      "accountCode": "1000",
      "entryType": 0, 
      "amount": 100.0,
      "currency": "USD",
      "memo": "User wallet debit"
    },
    {
      "accountCode": "2100",
      "entryType": 1,
      "amount": 100.0,
      "currency": "USD",
      "memo": "Project pool credit"
    }
  ]
}
```
*(Note: `entryType: 0` = Debit, `entryType: 1` = Credit)*

**Success Response (201 Created):**
```json
{
  "transactionId": "ledger-guid",
  "reference": "TRX-12345",
  "source": "ProjectFund",
  "postedAtUtc": "2026-05-07T10:00:05Z",
  "totalDebits": 100.0,
  "totalCredits": 100.0
}
```

**Error Responses:**
- **400 Bad Request** (Debits and credits do not match, or invalid account code).

---

## 5. Contributions (`/contributions`)
*Requires `Authorization: Bearer <token>`*

### 5.1. Get Contribution Config
Retrieves the project's funding rules and the user's available wallets.

**`GET /contributions/projects/{projectId}/config`**

**Success Response (200 OK):**
```json
{
  "projectId": "project-guid",
  "projectCurrency": "USD",
  "platformFeeRatePercent": 15.0,
  "minimumContributionAmount": 5.0,
  "isNonRefundable": true,
  "suggestedContributionAmount": 100.0,
  "wallets": [
    {
      "walletId": "wallet-guid",
      "currency": "USD",
      "availableBalance": 1050.0,
      "lockedBalance": 0.0,
      "borrowedBalance": 0.0
    }
  ]
}
```

**Error Responses:**
- **404 Not Found** (Project not found).

---

### 5.2. Preview Contribution
Calculates the breakdown of amounts and fees without performing the transaction.

**`POST /contributions/preview`**

**Request Body:**
```json
{
  "projectId": "project-guid",
  "membershipId": "membership-guid",
  "walletId": "wallet-guid",
  "amount": 100.0,
  "currency": "USD",
  "externalReference": null,
  "confirmNonRefundable": true
}
```

**Success Response (200 OK):**
```json
{
  "contributionAmount": 100.0,
  "platformFeeAmount": 15.0,
  "walletDeductionAmount": 100.0,
  "projectPotCreditAmount": 100.0,
  "walletBalanceBefore": 1050.0,
  "walletBalanceAfter": 950.0,
  "projectPotBalanceBefore": 5000.0,
  "projectPotBalanceAfter": 5100.0,
  "currency": "USD",
  "nonRefundableAcknowledged": true
}
```

**Error Responses:**
- **400 Bad Request** (Insufficient funds):
```json
{
  "title": "Insufficient funds",
  "detail": "Wallet balance is lower than the contribution amount."
}
```

---

### 5.3. Confirm Contribution
Executes the payment and updates ledger balances.

**`POST /contributions/confirm`**

**Request Body:** (Same as Preview endpoint)
```json
{
  "projectId": "project-guid",
  "membershipId": "membership-guid",
  "walletId": "wallet-guid",
  "amount": 100.0,
  "currency": "USD",
  "externalReference": "STRIPE-123",
  "confirmNonRefundable": true
}
```

**Success Response (200 OK):**
```json
{
  "contributionId": "contrib-guid",
  "paymentTransactionId": "payment-guid",
  "projectId": "project-guid",
  "contributionAmount": 100.0,
  "platformFeeAmount": 15.0,
  "walletDeductionAmount": 100.0,
  "projectPotCreditAmount": 100.0,
  "walletBalanceAfter": 950.0,
  "projectPotBalanceAfter": 5100.0,
  "currency": "USD",
  "receivedAtUtc": "2026-05-07T10:05:00Z",
  "message": "Contribution successful"
}
```

**Error Responses:**
- **400 Bad Request** (Confirmation required):
```json
{
  "title": "Confirmation required",
  "detail": "Please acknowledge that this contribution is non-refundable."
}
```
- **409 Conflict** (External reference already exists)
- **500 Internal Server Error** (Ledger config missing).

---

### 5.4. List Project Contributions
**`GET /contributions?projectId={projectId}`**

**Success Response (200 OK):**
```json
[
  {
    "id": "contrib-guid",
    "projectId": "project-guid",
    "membershipId": "membership-guid",
    "walletId": "wallet-guid",
    "grossAmount": 100.0,
    "platformFeeAmount": 15.0,
    "netAmount": 100.0,
    "currency": "USD",
    "status": "Posted",
    "externalReference": "STRIPE-123",
    "receivedAtUtc": "2026-05-07T10:05:00Z"
  }
]
```

---

### 5.5. Get Contribution By ID
**`GET /contributions/{id}`**

**Success Response (200 OK):**
```json
{
  "id": "contrib-guid",
  "projectId": "project-guid",
  "membershipId": "membership-guid",
  "walletId": "wallet-guid",
  "paymentTransactionId": "payment-guid",
  "grossAmount": 100.0,
  "platformFeeAmount": 15.0,
  "netAmount": 100.0,
  "currency": "USD",
  "status": "Posted",
  "externalReference": "STRIPE-123",
  "receivedAtUtc": "2026-05-07T10:05:00Z"
}
```

**Error Responses:**
- **404 Not Found**

---

### 5.6. Get Project Pot Balance
**`GET /contributions/projects/{projectId}/pot-balance`**

**Success Response (200 OK):**
```json
{
  "projectId": "project-guid",
  "potBalance": 5100.0,
  "currency": "USD"
}
```

**Error Responses:**
- **404 Not Found**

---

### 5.7. Get Wallet Balance
**`GET /contributions/wallets/{walletId}/balance`**

**Success Response (200 OK):**
```json
{
  "walletId": "wallet-guid",
  "currency": "USD",
  "availableBalance": 950.0,
  "lockedBalance": 0.0,
  "borrowedBalance": 0.0
}
```

**Error Responses:**
- **404 Not Found**

---

### 5.8. Award VFF Badge to Top Contributor
Calculates the top contributor for a project and awards them the `VFFBadge` role.

**`POST /contributions/projects/{projectId}/award-vff-badge`**

**Request Body:** (Empty)

**Success Response (200 OK):**
```json
{
  "projectId": "project-guid",
  "membershipId": "membership-guid",
  "userId": "user-guid",
  "userName": "johndoe",
  "totalContributedAmount": 1500.0,
  "badgeCode": "VFF",
  "message": "VFF badge awarded to top contributor."
}
```

**Error Responses:**
- **404 Not Found** (Project not found).
- **400 Bad Request** (No contributions found):
```json
{
  "title": "No contributions found",
  "detail": "No posted contributions exist for this project yet."
}
```
