import express from 'express';
import dotenv from 'dotenv/config';
import cors from 'cors';
import userRouter from './routes/user.routes.js';


//server function
const app = express();



//middleware
app.use(express.json());
app.use(cors({
    origin: "http://localhost:3000/",  credentials: true}));res.cookie("refresh_token", token, {
    httpOnly: true,  secure: true,  sameSite: "none",  domain: ".example.com"
});

app.get('/');
app.use("/api/user", userRouter);



const PORT = process.env.PORT || 3000;
app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`);
})




