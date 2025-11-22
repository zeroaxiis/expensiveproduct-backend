import { Router } from 'express';
import { userSignup } from '../controller/user.controller.js';
import { upload } from '../middleware/multer.middleware.js';

const userRouter = Router();
//user signup route
userRouter.post('/signup', upload.none(), userSignup)

export default userRouter;
