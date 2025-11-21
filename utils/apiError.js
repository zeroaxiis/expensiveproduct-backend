class ApiError extends Error{
    constructor(
        statusCode,
        message= "something went Wrong",
        errors = [],
        stack = ""
    ){
        super(message);
        this.statusCode = statusCode;
        this.data = null;
        this.success = false;
        this.errors= errors;


        if(stack){
            this.stack = stack;

        }else{
            Error.captureStackTrace(this, this.constructor);
        }
        // this.stack = stack;
    }
}


export {ApiError};