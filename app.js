import express from 'express';
import 'dotenv/config';
import cors from 'cors';
import db from './config/db.js';
import userRoutes from './route/user.route.js';
// import { user } from 'pg/lib/defaults';

//server function
const app = express();
const corsOptions = {
    origin: 'http://localhost:3002',
    credentials: true,
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};


//middleware
app.use(express.json());
app.use(cors(corsOptions));
app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));

//routes
app.get('/',(req,res)=>{
    res.send("Welcome to the Expense Manager API")
});
app.use('/api/v1/user',userRoutes);




const PORT = process.env.PORT || 3000;
app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`);
})




