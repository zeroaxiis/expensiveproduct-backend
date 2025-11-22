import { Router } from 'express';
import { userSignup } from '../controller/user.controller.js';

const userRouter = Router();
//user signup route
userRouter.post('/signup', userSignup)

export default userRouter;
