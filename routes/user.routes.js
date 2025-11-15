import { Router } from "express";
import registerUser from "../controllers/registerUser.controller.js";
const userRouter = Router();

userRouter.post("/register", registerUser);
