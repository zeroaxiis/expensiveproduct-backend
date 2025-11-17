import express from 'express';
import dotenv from 'dotenv/config';
import cors from 'cors';
import db from './config/db.js';


//server function
const app = express();
const corsOptions = {
    origin: 'http://localhost:3000',
    credentials: true,
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};


//middleware
app.use(express.json());
app.use(cors(corsOptions));

//routes
app.get('/',(req,res)=>{
    res.send("Welcome to the Expense Manager API")
});




const PORT = process.env.PORT || 3000;
app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`);
})




