# 23 - URL Obfuscation & Security Guide (Hashed Portfolio Links)

## Overview
Previously, public portfolio URLs exposed raw database primary keys in the query string:
```
Portfolio.aspx?userId=1
Portfolio.aspx?userId=2
```
This opened up an **IDOR (Insecure Direct Object Reference)** vulnerability, allowing any visitor to guess or scrape other users' portfolios simply by incrementing or decrementing the numeric ID.

To prevent enumeration attacks without requiring changes to the SQL Server database schema, the application implements **URL-Safe Symmetric AES Obfuscation**. The integer `UserID` is encrypted into an unguessable, URL-safe alphanumeric token:
```
Portfolio.aspx?u=3kR9xLpQ2vM...
```

---

## Architectural Workflow

```
+-------------------------------------------------------------+
|                      Link Generation                        |
|                                                             |
|   UserID (e.g. 1) ---> UrlObfuscator.EncodeUserId(1)        |
|                                  |                          |
|                                  v                          |
|               Portfolio.aspx?u=vP9Lz8K_12eF                 |
+-------------------------------------------------------------+
                               |
                               | (Visitor requests page)
                               v
+-------------------------------------------------------------+
|                      Token Resolution                       |
|                                                             |
|   Request.QueryString["u"] ---> UrlObfuscator.DecodeUserId  |
|                                  |                          |
|         +------------------------+-----------------------+  |
|         | Valid Token                                    | Tampered/Corrupt
|         v                                                v  
|   UserID = 1                                         UserID = 0
|   (Load Portfolio)                           (Redirect / Access Denied)
+-------------------------------------------------------------+
```

---

## Core Component: `UrlObfuscator.cs`

**Location**: [`Backend/Common/UrlObfuscator.cs`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Common/UrlObfuscator.cs)  
**Registered in Project**: [`241611JalopPersonalWebsite.csproj`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/241611JalopPersonalWebsite.csproj#L208)

### Key Specifications:
- **Algorithm**: Standard AES (Advanced Encryption Standard).
- **Key & IV**: 128-bit secret key and initialization vector.
- **URL-Safe Base64**:
  - `+` is converted to `-`
  - `/` is converted to `_`
  - Trailing `=` padding characters are trimmed off.
- **Fail-Safe Tamper Resistance**: Any modified, corrupt, or forged token triggers a cryptographic exception inside `try/catch` and returns `0`, preventing runtime errors or data leakage.

```csharp
// Example Usage:
string token = UrlObfuscator.EncodeUserId(1);  // Returns URL-safe token
int userId = UrlObfuscator.DecodeUserId(token); // Returns 1, or 0 if invalid
```

---

## Integration Touchpoints

### 1. Portfolio Page Resolution & Sharing
**File**: [`Frontend/User/Portfolio.aspx.cs`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx.cs)

- **`ResolveTargetUserId()`**:
  1. Checks `Request.QueryString["u"]`. If present, decodes it via `UrlObfuscator.DecodeUserId(token)`.
  2. Fallback check for `Request.QueryString["userId"]`: **Strictly restricted**. Only authenticated **Admins** or the user viewing their own account can use direct numeric IDs. Unauthenticated visitors cannot enumerate IDs.
  3. Checks `Session["UserID"]` for logged-in owners viewing their own page.
  4. If unresolved, safely redirects to the Login page.
- **`LoadPortfolio(int userId)`**:
  - Generates the shareable link with the obfuscated token:
    ```csharp
    string token = UrlObfuscator.EncodeUserId(userId);
    ShareUrl = $"{scheme}://{authority}{path}?u={token}";
    ```

### 2. User Dashboard
**File**: [`Frontend/User/Dashboard.aspx.cs`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Dashboard.aspx.cs#L44)

- The "View Portfolio" button generates the encrypted link:
  ```csharp
  lnkViewPortfolio.NavigateUrl = $"Portfolio.aspx?u={UrlObfuscator.EncodeUserId(userId)}";
  ```

### 3. Login Redirection
**File**: [`Frontend/Login/Login.aspx.cs`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Login/Login.aspx.cs#L119)

- After successful authentication, regular users are redirected to their portfolio with the obfuscated link:
  ```csharp
  string redirectUrl = isAdmin 
      ? "../Admin/Dashboard.aspx" 
      : $"../User/Portfolio.aspx?u={UrlObfuscator.EncodeUserId(authenticatedUser.UserID)}";
  ```

### 4. Admin Dashboard User Summary Modal
**File**: [`Frontend/Admin/Dashboard.aspx.cs`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Admin/Dashboard.aspx.cs#L260)

- The "View Public Portfolio" button inside the user details modal uses the obfuscated link:
  ```csharp
  lnkSummaryPortfolio.NavigateUrl = $"~/Frontend/User/Portfolio.aspx?u={UrlObfuscator.EncodeUserId(userId)}";
  ```

---

## Security Verification Checklist

| Scenario | Request | Expected Result | Verified Status |
| :--- | :--- | :--- | :--- |
| **Valid Obfuscated Link** | `Portfolio.aspx?u={validToken}` | Portfolio loads successfully for the corresponding user | Pass |
| **Tampered / Forged Token** | `Portfolio.aspx?u=randomInvalid123` | Decrypts to `0` $\rightarrow$ Redirects to login with message | Pass |
| **Direct Integer Guess (Guest)** | `Portfolio.aspx?userId=2` | Blocked (unauthorized) $\rightarrow$ Redirects to login | Pass |
| **Direct Integer (Admin)** | `Portfolio.aspx?userId=2` | Allowed for administration and debugging | Pass |
| **Share Link Copy** | Copy Link button on Portfolio | Copies `?u={token}` URL; raw integer is never exposed | Pass |

---

## Maintenance Notes
- If the secret key in `UrlObfuscator.cs` is changed, all previously generated portfolio links will be invalidated. To prevent link breakage across redeployments, keep the key and IV constant or store them in `Web.config` `appSettings`.
