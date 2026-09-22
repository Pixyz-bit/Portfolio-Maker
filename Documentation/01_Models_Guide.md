# 01 - Models Guide & Architecture in ASP.NET

## 1. What is a Model?
In an ASP.NET application, a **Model** is a C# class that represents the shape of your data.
It acts as a data carrier (or Data Transfer Object / DTO) between:
1. **User Interface (`.aspx` Web Forms)**: Input fields like textboxes and dropdowns.
2. **Code-Behind (`.aspx.cs`)**: Business and validation logic.
3. **Repository (`DatabaseConnection.cs` / Data Access)**: Sending and receiving data from SQL Server tables.

---

## 2. Directory & Namespace Convention
All model classes in this project reside inside the `Model/` folder.

- **Folder Path**: `241611JalopPersonalWebsite/Model/`
- **Namespace**: `_241611JalopPersonalWebsite.Model`

Any file (such as a page or repository) that needs to use models must include:
```csharp
using _241611JalopPersonalWebsite.Model;
```

---

## 3. The `UserLogin` Model Specification

### Attributes / Properties
| Property Name | Data Type | Purpose | Corresponding Database Column |
| :--- | :--- | :--- | :--- |
| `UserID` | `int` | Unique identifier | `Users.UserID` (Primary Key) |
| `FirstName` | `string` | User's given first name | `UserProfiles.FirstName` |
| `LastName` | `string` | User's family/last name | `UserProfiles.LastName` |
| `Email` | `string` | User email / login credential | `Users.Email` |
| `Password` | `string` | Plain-text password during input | Hashed to `Users.PasswordHash` |

---

## 4. Understanding Constructors in Models

### A. The Parameterless Constructor (`public UserLogin() { }`)
```csharp
public UserLogin()
{
}
```
- **Why it is needed**:
  1. **Object Initializer Syntax**: Allows setting only the fields you need using `{ ... }` syntax:
     ```csharp
     UserLogin user = new UserLogin
     {
         Email = "user@example.com",
         Password = "SecretPassword123"
     };
     ```
  2. **Framework & Serialization Support**: Many ASP.NET tools, serializers (like JSON.NET), and database mappers require a parameterless constructor to instantiate the object before setting values.
  3. **The C# Rule**: If you do not write any constructors, C# gives you a default parameterless one for free. But the moment you add a custom parameterized constructor, C# removes the default one. Writing `public UserLogin() { }` ensures you retain default instantiation.

---

### B. The Overloaded Parameterized Constructor
```csharp
public UserLogin(string firstName, string lastName, string email, string password)
{
    FirstName = firstName;
    LastName = lastName;
    Email = email;
    Password = password;
}
```
- **Why it is needed**:
  - **Single-Line Initialization**: Quickly create a fully populated model in one step:
    ```csharp
    UserLogin user = new UserLogin("John", "Doe", "john@example.com", "MyP@ss123");
    ```
- **What "Overloading" Means**:
  - In C#, "Constructor Overloading" means having multiple constructors with the same name (`UserLogin`) but different parameter lists. It gives developers the flexibility to choose the most convenient way to create an object.

---

## 5. Complete Implementation Snippet

File: `241611JalopPersonalWebsite/Model/UserLogin.cs`

```csharp
using System;

namespace _241611JalopPersonalWebsite.Model
{
    /// <summary>
    /// Model class representing user authentication, registration, and session details.
    /// </summary>
    public class UserLogin
    {
        // Database identifier
        public int UserID { get; set; }

        // User personal information
        public string FirstName { get; set; }
        public string LastName { get; set; }

        // Authentication credentials
        public string Email { get; set; }
        public string Password { get; set; }

        /// <summary>
        /// Default parameterless constructor.
        /// Required for object initializers and serialization frameworks.
        /// </summary>
        public UserLogin()
        {
        }

        /// <summary>
        /// Overloaded constructor for registration workflows.
        /// </summary>
        public UserLogin(string firstName, string lastName, string email, string password)
        {
            FirstName = firstName;
            LastName = lastName;
            Email = email;
            Password = password;
        }

        /// <summary>
        /// Overloaded constructor when loading existing users from database queries.
        /// </summary>
        public UserLogin(int userId, string firstName, string lastName, string email, string password)
        {
            UserID = userId;
            FirstName = firstName;
            LastName = lastName;
            Email = email;
            Password = password;
        }
    }
}
```

---

## 6. Step-by-Step Usage Guide

### Step 1: In a Registration Form Code-Behind (`Register.aspx.cs`)
When a user submits a registration form, capture the input textboxes into a `UserLogin` model:

```csharp
using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite
{
    public partial class Register : Page
    {
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Way 1: Using the Parameterless Constructor with Object Initializer
            UserLogin newUser = new UserLogin
            {
                FirstName = txtFirstName.Text.Trim(),
                LastName = txtLastName.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                Password = txtPassword.Text
            };

            // Way 2: Using the Overloaded Constructor
            // UserLogin newUser = new UserLogin(txtFirstName.Text.Trim(), txtLastName.Text.Trim(), txtEmail.Text.Trim(), txtPassword.Text);

            // Pass the model to your Repository layer
            // bool success = UserRepository.Register(newUser);
        }
    }
}
```

### Step 2: In a Database Repository (`UserRepository.cs`)
When receiving a `UserLogin` model, read its properties directly to prepare SQL parameters:

```csharp
using System;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public class UserRepository
    {
        public static bool InsertUser(UserLogin user)
        {
            // Access properties cleanly via user.FirstName, user.LastName, user.Email, user.Password
            string email = user.Email;
            string firstName = user.FirstName;
            string lastName = user.LastName;
            string password = user.Password;

            // Database insert logic here...
            return true;
        }
    }
}
```

---

## 7. Next Numbered Documentation Files Roadmap
- `02_Repository_Pattern_Guide.md` (Database operations and parameterized queries)
- `03_Authentication_Session_Guide.md` (Password hashing, login verification, session storage)
