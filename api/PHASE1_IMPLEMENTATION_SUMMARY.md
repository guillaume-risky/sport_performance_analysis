# Phase 1 Implementation Summary: Current User + Academy Base

## Files Changed

### Database Migrations
1. **`api/src/main/resources/db/migration/V9__academy_and_user_academy.sql`** (NEW)
   - Creates `academy` table with BIGSERIAL id, BIGINT academy_number
   - Adds `academy_number BIGINT` column to `app_user`
   - Adds foreign key constraint `app_user.academy_number -> academy.academy_number`
   - Creates indexes

### Domain & Repository Layer
2. **`api/src/main/java/com/sportperformance/api/academy/Academy.java`** (NEW)
   - Record with id, academyNumber, name, logoUrl, primaryColor, createdAt

3. **`api/src/main/java/com/sportperformance/api/academy/AcademyRepository.java`** (NEW)
   - JdbcTemplate repository for academy table
   - Methods: save, findByAcademyNumber, existsByAcademyNumber

4. **`api/src/main/java/com/sportperformance/api/academy/AcademyService.java`** (NEW)
   - Business logic for academy operations
   - Generates unique 9-digit academyNumber with retry on conflict

5. **`api/src/main/java/com/sportperformance/api/user/User.java`** (MODIFIED)
   - Added `academyNumber` field (Long)

6. **`api/src/main/java/com/sportperformance/api/user/UserRepository.java`** (MODIFIED)
   - Updated ROW_MAPPER to include academy_number
   - Updated save() and findByEmail() to handle academy_number

7. **`api/src/main/java/com/sportperformance/api/user/UserService.java`** (MODIFIED)
   - Updated createUser() to set academyNumber to null

### Security & Authentication
8. **`api/src/main/java/com/sportperformance/api/auth/OtpService.java`** (MODIFIED)
   - Updated to pass academyNumber to SecurityUserPrincipal

### Controllers & Endpoints
9. **`api/src/main/java/com/sportperformance/api/user/UserController.java`** (NEW)
   - GET /api/v1/me - Returns current user info

10. **`api/src/main/java/com/sportperformance/api/user/MeResponse.java`** (NEW)
    - Response DTO for /api/v1/me

11. **`api/src/main/java/com/sportperformance/api/academy/AcademyController.java`** (NEW)
    - POST /api/v1/academies - Create academy (ADMIN only)
    - GET /api/v1/academies/me - Get current user's academy

12. **`api/src/main/java/com/sportperformance/api/academy/AcademyRequest.java`** (NEW)
    - Request DTO for POST /api/v1/academies

13. **`api/src/main/java/com/sportperformance/api/academy/AcademyResponse.java`** (NEW)
    - Response DTO for academy endpoints

### Error Handling
14. **`api/src/main/java/com/sportperformance/api/academy/AcademyNotSetException.java`** (NEW)
    - Exception when user has no academy assigned

15. **`api/src/main/java/com/sportperformance/api/academy/AcademyNotFoundException.java`** (NEW)
    - Exception when academy not found

16. **`api/src/main/java/com/sportperformance/api/error/GlobalExceptionHandler.java`** (MODIFIED)
    - Added handlers for AcademyNotSetException (404, ACADEMY_NOT_SET)
    - Added handlers for AcademyNotFoundException (404, ACADEMY_NOT_FOUND)

### Tests
17. **`api/src/test/java/com/sportperformance/api/testsupport/TestJwtHelper.java`** (NEW)
    - Helper to create JWT tokens for tests

18. **`api/src/test/java/com/sportperformance/api/user/UserControllerTest.java`** (NEW)
    - testGetMe_Authenticated_Returns200
    - testGetMe_NoAcademy_Returns200WithNullAcademy

19. **`api/src/test/java/com/sportperformance/api/academy/AcademyControllerTest.java`** (NEW)
    - testCreateAcademy_NonAdmin_Returns403
    - testCreateAcademy_Admin_Returns200
    - testGetMyAcademy_NotSet_Returns404
    - testGetMyAcademy_AcademyNotFound_Returns404
    - testGetMyAcademy_Set_Returns200

20. **`api/src/test/java/com/sportperformance/api/auth/AuthControllerTest.java`** (MODIFIED)
    - Updated setUp() to include academy table cleanup

### Dependencies
21. **`api/pom.xml`** (MODIFIED)
    - Added spring-security-test dependency

### Fixed Issues
22. **`api/src/main/java/com/sportperformance/api/invite/InviteToken.java`** (MODIFIED)
    - Changed academyId (UUID) to academyNumber (String) to match schema

23. **`api/src/main/java/com/sportperformance/api/invite/InviteRepository.java`** (MODIFIED)
    - Updated to use academy_number column

24. **`api/src/main/java/com/sportperformance/api/invite/InviteService.java`** (MODIFIED)
    - Updated to parse academyNumber as Long and use String in InviteToken

## Commands to Run Tests

```powershell
# Ensure Docker Desktop is running first!

# Run all tests
cd C:\Cursor\sport_performance_analysis\api
mvn clean test

# Run specific test classes
mvn test -Dtest=UserControllerTest
mvn test -Dtest=AcademyControllerTest
mvn test -Dtest=AuthControllerTest

# Run all Phase 1 related tests
mvn test -Dtest=UserControllerTest,AcademyControllerTest
```

## Demo PowerShell Commands

### 1. Request OTP
```powershell
$body = @{
    email = "admin@example.com"
    purpose = "login"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/otp/request" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

Write-Host "OTP Request Response:"
$response | ConvertTo-Json
```

### 2. Verify OTP (get token from console logs)
```powershell
# Check console for OTP code, then:
$body = @{
    email = "admin@example.com"
    purpose = "login"
    otp = "123456"  # Replace with actual OTP from console
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/otp/verify" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

$token = $response.accessToken
Write-Host "Token: $token"
```

### 3. Call GET /api/v1/me
```powershell
$headers = @{
    Authorization = "Bearer $token"
}

$me = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/me" `
    -Method GET `
    -Headers $headers

Write-Host "Current User:"
$me | ConvertTo-Json
```

### 4. Create Academy (requires ADMIN role)
```powershell
$body = @{
    name = "My Academy"
    logoUrl = "https://example.com/logo.png"
    primaryColor = "#112233"
} | ConvertTo-Json

$academy = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/academies" `
    -Method POST `
    -ContentType "application/json" `
    -Headers $headers `
    -Body $body

Write-Host "Created Academy:"
$academy | ConvertTo-Json

$academyNumber = $academy.academyNumber
Write-Host "Academy Number: $academyNumber"
```

### 5. Call GET /api/v1/academies/me
```powershell
$myAcademy = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/academies/me" `
    -Method GET `
    -Headers $headers

Write-Host "My Academy:"
$myAcademy | ConvertTo-Json
```

## Complete Demo Script

```powershell
# Set variables
$email = "admin@example.com"
$baseUrl = "http://localhost:8080"

# 1. Request OTP
Write-Host "`n=== Step 1: Request OTP ===" -ForegroundColor Cyan
$body = @{ email = $email; purpose = "login" } | ConvertTo-Json
$otpRequest = Invoke-RestMethod -Uri "$baseUrl/api/v1/auth/otp/request" `
    -Method POST -ContentType "application/json" -Body $body
Write-Host "Check console for OTP code" -ForegroundColor Yellow
$otp = Read-Host "Enter OTP code from console"

# 2. Verify OTP
Write-Host "`n=== Step 2: Verify OTP ===" -ForegroundColor Cyan
$body = @{ email = $email; purpose = "login"; otp = $otp } | ConvertTo-Json
$verifyResponse = Invoke-RestMethod -Uri "$baseUrl/api/v1/auth/otp/verify" `
    -Method POST -ContentType "application/json" -Body $body
$token = $verifyResponse.accessToken
Write-Host "Token obtained: $($token.Substring(0, 20))..." -ForegroundColor Green

# 3. Get current user
Write-Host "`n=== Step 3: GET /api/v1/me ===" -ForegroundColor Cyan
$headers = @{ Authorization = "Bearer $token" }
$me = Invoke-RestMethod -Uri "$baseUrl/api/v1/me" -Method GET -Headers $headers
$me | ConvertTo-Json

# 4. Create Academy (if ADMIN)
Write-Host "`n=== Step 4: POST /api/v1/academies ===" -ForegroundColor Cyan
$body = @{
    name = "My Academy"
    logoUrl = "https://example.com/logo.png"
    primaryColor = "#112233"
} | ConvertTo-Json
try {
    $academy = Invoke-RestMethod -Uri "$baseUrl/api/v1/academies" `
        -Method POST -ContentType "application/json" -Headers $headers -Body $body
    Write-Host "Academy created:" -ForegroundColor Green
    $academy | ConvertTo-Json
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 5. Get my academy
Write-Host "`n=== Step 5: GET /api/v1/academies/me ===" -ForegroundColor Cyan
try {
    $myAcademy = Invoke-RestMethod -Uri "$baseUrl/api/v1/academies/me" `
        -Method GET -Headers $headers
    Write-Host "My Academy:" -ForegroundColor Green
    $myAcademy | ConvertTo-Json
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
```

## Key Features Implemented

✅ **Academy Table**: BIGSERIAL id, BIGINT academy_number (unique), name, logo_url, primary_color
✅ **User-Academy Link**: app_user.academy_number foreign key to academy.academy_number
✅ **GET /api/v1/me**: Returns current user with academyNumber
✅ **POST /api/v1/academies**: ADMIN-only endpoint, generates unique 9-digit academyNumber
✅ **GET /api/v1/academies/me**: Returns user's academy or 404 if not set/not found
✅ **RBAC Enforcement**: @PreAuthorize on POST /api/v1/academies
✅ **Error Handling**: ACADEMY_NOT_SET and ACADEMY_NOT_FOUND error codes
✅ **Integration Tests**: All endpoints covered with Testcontainers
✅ **No Breaking Changes**: Existing OTP endpoints remain functional

## Notes

- Academy numbers are 9-digit random numbers (100000000-999999999)
- Retry logic ensures uniqueness (up to 10 attempts)
- Foreign key enforces referential integrity
- All endpoints require JWT authentication except OTP endpoints
- Tests use Testcontainers PostgreSQL (requires Docker)
