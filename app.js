import express from 'express';
import dotenv from 'dotenv/config';
import cors from 'cors';
import userRouter from './routes/user.routes.js';



const app = express();
app.use(express.json());
app.use(cors({
    origin:"",
    credentials:true
}))


app.get('/');
app.use("/api/user", userRouter);



const PORT = process.env.PORT || 3000;
app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`);
})




