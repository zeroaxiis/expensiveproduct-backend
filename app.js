import express from 'express';
import dotenv from 'dotenv/config';
const app = express();




const PORT = process.env.PORT || 3000;
app.get('/',(req,res)=>{
    res.send('hello this is the backend server')
})



app.listen(PORT,()=>{
    console.log(`server is running on port ${PORT}`);
})




