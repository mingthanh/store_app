// MongoDB Query - Paste vào MongoDB Compass hoặc mongosh

// Kiểm tra user role
db.users.find({ email: "tranthikimthanh230@gmail.com" })

// Expected result:
{
  "_id": ObjectId("..."),
  "email": "tranthikimthanh230@gmail.com",
  "name": "...",
  "role": 0,  // ← Phải là 0 (admin/staff)
  "password": "...",
  "createdAt": ISODate("...")
}

// Nếu role không phải 0, update:
db.users.updateOne(
  { email: "tranthikimthanh230@gmail.com" },
  { $set: { role: 0 } }
)
