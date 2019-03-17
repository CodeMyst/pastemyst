module.exports = (gulp, paths, $, _) => {
    return gulp.src('src/views/*.pug')
        .pipe($.environment.if.development($.sourcemaps.init()))
        // .pipe($.styleAliases({
        //     '~styles/variables': './src/styles/base/variables'
        // }))
        // .pipe($.sass().on('error', $.sass.logError))
        // .pipe($.autoprefixer({ browsers: ['last 2 versions'] }))
        // .pipe($.replace('> > >', '>>>')) // deep combinator fix
        // .pipe($.environment.if.production($.cleanCss()))
        .pipe($.pug())
        .pipe($.environment.if.development($.sourcemaps.write()))
        .pipe(gulp.dest("dist"));
};