import db from '../config/db.js';
import { users } from '../db/schema/users.js';
import bcrypt from 'bcrypt';
import { eq } from 'drizzle-orm';
import jwt from 'jsonwebtoken';
import { createRequire } from 'module';
import crypto from 'crypto';
import { ApiError } from '../utils/apiError.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';
const require = createRequire(import.meta.url);
const { createNewOTP, verifyOTP } = require('../lib/otp-without-db/index.cjs');

//user Signup logic
const userSignup = asyncHandler(async (req, res) => {
    const { email, name, password } = req.body;
    if (!email || !name || !password) {
        throw new ApiError(400, " All fields are Required");
    }
    const existingUser = await db.select().from(users).where(eq(users.email, email)).limit(1);
    if (existingUser.length > 0) {
        throw new ApiError(400, "User already Exists");
    }

    //hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        await db.insert(users).values({
            email,
            name,
            passwordHash: hashedPassword
        });

        return res.status(201).json(
            new ApiResponse(201, userSignup, "user registered successfully")
        )
    } catch {
        throw new ApiError(400, "something went wrong while registering the user")
    }
});

const userLogin = async (req, res) => {
    const { email, password } = req.body;
}

export { userSignup }
