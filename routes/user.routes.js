import { Router } from "express";
import registerUser from "../controllers/registerUser.controller.js";
const userRouter = Router();

userRouter.post("/register", registerUser);
userRouter.post("/login", loginUser);



export {userRouter,userLogin} 