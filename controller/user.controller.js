import db from '../config/db.js';
import { users } from '../db/schema/users.js';
import bcrypt from 'bcrypt';
import { eq } from 'drizzle-orm';
import jwt from 'jsonwebtoken';
import { createRequire } from 'module';
import crypto from 'crypto';
const require = createRequire(import.meta.url);
const { createNewOTP, verifyOTP } = require('../lib/otp-without-db/index.cjs');


//user Signup logic
const userSignup = async(req,res)=>{
    const {email,name,password,profilePicture,timezone,currency} = req.body;
    if(!email ||!name ||!password ||!profilePicture ||!timezone ||!currency){
        return res.status(400).json({
            errorMessage:" All fields are Required"
        });
    }
    const existingUser = await db.select().from(users).where(eq(users.email,email).limit(1))
    if(existingUser.length>0){
        return res.status(400).json({
            errorMessage:"User already Exists"
        });
    }
    
    //hash the password
    const hashedPassword = await bcrypt.hash(password,10);
    try{
        const result = await pool.query(
            `INSERT INTO users() values(email,name, hashedPassword, profilePicture,timezone currency)`
            [email,name,hashedPassword, profilePicture,timezone,currency]
        )

    }catch(error){
        
    }
}

const userLogin= async(req,res)=>{
    const {email,password}= req.body;   
}




export { userSignup}


