# Backend Bug Report: Member Registration Issue

## 🐛 Bug Description

The backend member registration endpoint has a critical bug that prevents registering members when optional fields (rifleNo, ninNo, bvn, accountNo) are not provided.

---

## 📍 Location

**File:** `/home/cjtfapi/cjtfBackend/src/modules/member/member.service.ts`  
**Line:** 134  
**Endpoint:** `POST /api/v1/admin/member`

---

## ❌ Current Behavior

When a member is registered WITHOUT providing a rifle number, the backend throws a Prisma error:

```
Invalid `prisma.member.findUnique()` invocation

const rifleNoExists = await prisma.member.findUnique({
  where: {
    rifleNo: undefined  // ❌ This causes the error
  }
});
```

**Error Message:**
```
500 Internal Server Error
"responseSuccessful": false
"responseMessage": "Invalid `prisma.member.findUnique()` invocation..."
```

---

## ✅ Expected Behavior

When optional fields are not provided in the request, the backend should:
1. Skip the uniqueness check for those fields
2. Allow member registration to proceed
3. Store `null` or omit the field in the database

---

## 🔍 Root Cause

The backend code is checking for rifle number uniqueness **unconditionally**, even when no rifle number is provided in the request payload.

**Current Backend Code (BUGGY):**
```typescript
// Line ~134 in member.service.ts
const rifleNoExists = await prisma.member.findUnique({
  where: {
    rifleNo: rifleNo  // This becomes 'undefined' when not provided
  }
});

if (rifleNoExists) {
  throw new Error('Rifle number already exists');
}
```

---

## 🛠️ Recommended Fix

Add a conditional check before querying the database:

```typescript
// ✅ FIXED CODE
if (rifleNo) {  // Only check if rifleNo was actually provided
  const rifleNoExists = await prisma.member.findUnique({
    where: {
      rifleNo: rifleNo
    }
  });

  if (rifleNoExists) {
    throw new Error('Rifle number already exists');
  }
}
```

Apply the same fix for other optional unique fields:
- `ninNo` (NIN Number)
- `bvn` (BVN Number)  
- `accountNo` (Account Number)
- `idNo` (ID Number) - if it's optional

---

## 📊 Impact

**Severity:** HIGH  
**Affected Feature:** Member Registration  
**User Impact:** Users cannot register members without providing optional fields

**Workaround Applied (Frontend):**
- Frontend now uses conditional field inclusion
- Optional fields are completely omitted from the request if empty
- This prevents the fields from being sent as `null` or `undefined`

**However:** The backend should still be fixed to handle this case properly, as other clients or API consumers may send `null` values.

---

## 🧪 Test Cases

### Test Case 1: Register member WITH rifle number
**Input:**
```json
{
  "fullName": "John Doe",
  "rifleNo": "12345",
  ...
}
```
**Expected:** ✅ Success (if rifle number is unique)

### Test Case 2: Register member WITHOUT rifle number
**Input:**
```json
{
  "fullName": "Jane Doe",
  // rifleNo not provided
  ...
}
```
**Expected:** ✅ Success  
**Current:** ❌ 500 Error

### Test Case 3: Register member with null rifle number
**Input:**
```json
{
  "fullName": "Bob Smith",
  "rifleNo": null,
  ...
}
```
**Expected:** ✅ Success  
**Current:** ❌ 500 Error

---

## 📝 Additional Notes

1. **Database Schema:** Ensure these fields are marked as optional/nullable in the Prisma schema
2. **Validation:** Consider adding proper validation middleware before the service layer
3. **Error Handling:** Return user-friendly error messages instead of exposing Prisma errors
4. **API Documentation:** Update API docs to clearly indicate which fields are optional

---

## 🔗 Related Issues

- Frontend workaround implemented in commit: `c7888cb`
- Frontend uses conditional field inclusion to avoid sending empty optional fields
- Same issue likely affects member update endpoint if it has similar validation logic

---

## 👥 Stakeholders

**Reported By:** Frontend Team  
**Assigned To:** Backend Team  
**Priority:** High  
**Date Reported:** February 25, 2026

---

## ✅ Verification Steps

After fixing, verify:
1. ✅ Can register member without rifleNo
2. ✅ Can register member without ninNo
3. ✅ Can register member without bvn
4. ✅ Can register member without accountNo
5. ✅ Can register member with all optional fields
6. ✅ Duplicate rifle number still throws proper error
7. ✅ Error messages are user-friendly

---

**Status:** 🔴 OPEN - Awaiting Backend Fix
