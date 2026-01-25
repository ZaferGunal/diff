const JwtStrategy = require("passport-jwt").Strategy;
const ExtractJwt = require("passport-jwt").ExtractJwt;

const User = require("../models/user");
const config = require("./dbconfig");

module.exports = function (passport) {
    let opts = {};

    // Token'ı HTTP header'dan alma
    // Token formatın:  "Authorization: jwt <token>"
    opts.jwtFromRequest = ExtractJwt.fromAuthHeaderWithScheme("jwt");

    // Secret key
    opts.secretOrKey = config.secret;

    // Strategy tanımlama
    passport.use(
        new JwtStrategy(opts, async (jwt_payload, done) => {
            try {
                // MongoDB id kontrolü
                const user = await User.findById(jwt_payload.id);

                if (user) {
                    return done(null, user);
                } else {
                    return done(null, false);
                }

            } catch (err) {
                return done(err, false);
            }
        })
    );
};
