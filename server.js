const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const connectDB = require("./config/db");
const passport = require("passport");
const bodyParser = require("body-parser");
const routes = require("./routes/index");


connectDB();

const app = express();

if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}

app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json());
app.use(routes);
app.use(passport.initialize());
require("./config/passport")(passport);


const PORT = process.env.PORT || 3000;

app.listen(PORT, console.log(`Server runing in ${process.env.NODE_ENV} mode one port ${PORT}`))