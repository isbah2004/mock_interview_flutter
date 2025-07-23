# Appwrite Database Setup for Mock Interview App

## Problem: User data not storing in database

The issue is that your Appwrite users collection doesn't have the required attributes defined. When the app tries to store user data during signup, it fails because the collection schema doesn't match the data being sent.

## Solution: Create Required Attributes

### Users Collection Attributes

You need to create the following attributes in your Appwrite `users` collection (`68777f1300324ee21d1e`):

1. **name** (String)

   - Type: String
   - Size: 255
   - Required: Yes
   - Array: No

2. **email** (String)

   - Type: String
   - Size: 320
   - Required: Yes
   - Array: No

3. **phone** (String)

   - Type: String
   - Size: 20
   - Required: No
   - Array: No

4. **emailVerification** (Boolean)

   - Type: Boolean
   - Required: Yes
   - Default: false

5. **photoUrl** (String)

   - Type: String
   - Size: 2048
   - Required: No
   - Array: No

6. **totalInterviews** (Integer)

   - Type: Integer
   - Required: Yes
   - Min: 0
   - Default: 0

7. **averageScore** (Float)
   - Type: Float
   - Required: Yes
   - Min: 0
   - Max: 100
   - Default: 0.0

## Step-by-Step Instructions:

1. **Go to Appwrite Console**

   - Open https://cloud.appwrite.io/console
   - Navigate to your project

2. **Access Database**

   - Go to "Databases" in the left sidebar
   - Click on your database (ID: `687765bf0013ce99c541`)

3. **Open Users Collection**

   - Click on "users" collection (ID: `68777f1300324ee21d1e`)

4. **Create Attributes**

   - Click on "Attributes" tab
   - For each attribute above, click "Create Attribute"
   - Select the appropriate type and enter the specifications

5. **Verify Setup**
   - After creating all attributes, try the signup flow again
   - Check the "Documents" tab to see if user data is being stored

## Quick Test

After setting up the attributes, test the signup process:

1. Run your app
2. Go to signup screen
3. Fill in the form and submit
4. Check Appwrite console → Databases → Users Collection → Documents
5. You should see a new document with the user's data

## Note

The current code has error handling that continues even if database storage fails (to prevent auth failure), but it logs the error. Check your debug console for any error messages during signup.
